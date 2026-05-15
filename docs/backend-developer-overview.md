# Backend integration overview (for backend / platform engineers)

This document describes how the **Money Manager** Flutter app talks to the server today, what contracts matter, and where to look in the repo. There is **no separate custom HTTP API** in phase 1: the mobile client uses **Supabase Auth** plus **PostgREST** against **PostgreSQL** with **Row Level Security (RLS)**.

---

## 1. Stack at a glance

| Layer | Technology |
|--------|------------|
| Client | Flutter (Dart), local DB **Drift** (SQLite) |
| Remote | **Supabase**: Auth, Postgres, auto-generated REST (PostgREST) |
| Client SDK | `supabase_flutter` (singleton client after bootstrap) |

**Configuration:** `SUPABASE_URL` and `SUPABASE_ANON_KEY` are passed at **compile time** via `--dart-define` (see root `README.md` and `docs/supabase_dev_setup.md`). The app can run **without** Supabase (local-only); cloud UI is gated when keys are missing.

---

## 2. Major product behaviour (cloud-related)

1. **Local-first:** Expenses are always written to the device database first. Cloud upload happens only when the user is signed in and sync runs.
2. **Auth-gated sync:** All remote reads/writes use the authenticated Supabase session (JWT). RLS enforces access.
3. **Household tenancy:** Expenses in Postgres are scoped by **`household_id`**. The app ensures the user belongs to a household (see §4).
4. **Incremental sync (phase 1):** Push pending local rows via **upsert**; pull rows with **`updated_at` > watermark** (milliseconds, client-side cursor stored in `SharedPreferences`).
5. **Conflict handling (phase 1):** Last-write-wins style merge on the client when applying pulled rows vs local `updated_at` (see `ExpenseRepository.applyRemoteExpenseRow`).

---

## 3. PostgreSQL schema (phase 1)

Canonical SQL lives in:

`supabase/migrations/20260417120000_phase1.sql`

### 3.1 Tables (summary)

- **`households`** — `id` (uuid), `name`, `created_at`.
- **`household_members`** — composite PK `(household_id, user_id)`; `user_id` references **`auth.users`**.
- **`expenses`** — one row per expense, keyed by **`id` (uuid)** (same id as the client’s local row). Scoped by **`household_id`** and **`auth_user_id`** (must match the writer’s `auth.uid()` for inserts/updates per RLS).

### 3.2 Important column semantics (`expenses`)

| Column | Notes |
|--------|--------|
| `amount_minor` | Integer minor units (e.g. cents). |
| `occurred_at`, `created_at`, `updated_at` | **Bigint epoch milliseconds** (not `timestamptz` on these fields). |
| `category_id` | Opaque string; catalog is local in the app today. |
| `budget_bucket`, `note`, `recurring_payment_id`, `remote_id`, `sync_status`, `server_updated_at` | Carried for parity with local model; client sets some on upsert. |

Indexes include `(household_id, updated_at desc)` for pull queries.

### 3.3 RLS (high level)

- **`user_household_ids()`** — `security definer` helper returning household ids for `auth.uid()`.
- **Select / insert / update / delete** on `expenses` require membership in the row’s `household_id`.
- **Insert/update** require `auth.uid() = auth_user_id` so users cannot forge another user’s `auth_user_id`.

Any backend change (new columns, policies, or triggers) should keep these rules consistent or the mobile client will start failing with policy errors or empty result sets.

---

## 4. Household lifecycle (client-driven)

Implemented in `lib/app/cloud_sync_controller.dart` → **`ensureHouseholdIfNeeded()`** (called from sync before push/pull):

1. If a **household id** is already cached locally (`SyncMetadataStore`) and the user is still a member of that household in Postgres, keep it.
2. If the cached id is stale (no membership), clear it.
3. If there is no valid cached id, query **`household_members`** for `user_id = current user id`; if a row exists, **cache** that `household_id` (supports reinstall / new device without creating rows from the client).
4. The app **does not** insert new `households` or `household_members` rows. Those must exist from **Supabase-side** flows (e.g. `accept_family_invite`, other RPCs/migrations, or manual SQL). Until the user is a member of at least one household, expense sync will not run (no `household_id`).

**Implication for backend:** Household and membership rows are created only where your SQL/RPCs allow; the client only resolves and caches an id the user already belongs to.

---

## 5. Expense sync API (what the client actually calls)

All remote expense I/O is centralized in **`lib/data/remote/expense_remote_gateway.dart`** (invoked only from **`lib/sync/sync_orchestrator.dart`**, not from UI).

### 5.1 Push (upsert)

- **Operation:** `POST` upsert to table **`expenses`** (Supabase `.upsert(...)`).
- **Payload:** Maps local row fields to snake_case columns, including `id`, `household_id`, `auth_user_id`, monetary and metadata fields, `updated_at`, etc.
- **Semantics:** Idempotent by primary key `id`; retries re-upsert the same logical expense.

### 5.2 Pull (incremental)

- **First sync / full catch-up:** `sinceUpdatedAtMs <= 0` → `select` all rows for `household_id`, ordered by `updated_at` ascending.
- **Incremental:** `select` where `household_id` matches and **`updated_at` > sinceUpdatedAtMs**, same ordering.
- **Watermark:** After a successful pull, the client stores **`max(updated_at)`** from returned rows (see `SyncMetadataStore` + orchestrator) for the next pull.

**Implication for backend:** Any server-side update to an expense row should bump **`updated_at`** in milliseconds, or the client may miss changes on incremental pull.

---

## 6. Auth

- **Provider:** Supabase **email + password** (see `lib/data/remote/auth_remote_gateway.dart`).
- **Session:** JWT attached automatically by the Supabase client on requests.
- **Sign-out:** Client clears session and local sync metadata keys related to household / pull cursor (see `CloudSyncController.signOut`).

Backend work is mostly **Supabase Auth configuration** (providers, email confirmation, password rules) rather than custom login APIs.

---

## 7. What is *not* synced in phase 1

The phase 1 migration and client gateway cover **expenses** (and household membership) only. Other app domains (categories, recurring templates, limits, preferences, etc.) remain **local-only** unless you extend schema + client in a future phase.

---

## 8. Repo pointers

| Topic | Location |
|--------|----------|
| SQL migration | `supabase/migrations/20260417120000_phase1.sql` |
| Dev Supabase setup | `docs/supabase_dev_setup.md` |
| Remote layer rules | `lib/data/remote/README.md` |
| Upsert / pull queries | `lib/data/remote/expense_remote_gateway.dart` |
| Sync pipeline (push → pull) | `lib/sync/sync_orchestrator.dart` |
| Household bootstrap | `lib/app/cloud_sync_controller.dart` |
| Product-level sync requirements | `openspec/specs/supabase-phase1-sync/spec.md` |

---

## 9. Suggested collaboration checklist

When you change the database or policies:

1. Update **`supabase/migrations/`** (or document manual steps) and communicate **breaking** column/policy renames.
2. Verify **RLS** with a real JWT (anon key + signed-in user), not only the service role.
3. Confirm **`updated_at`** behaviour for anything that should appear on **incremental pull**.
4. If you introduce **Edge Functions** or **webhooks**, specify how the mobile app should discover or call them (today it does not depend on them for phase 1 expense sync).

---

*Document generated for sharing with backend / platform developers. For Flutter-specific structure, see `.cursor/rules/project_structure.mdc`.*
