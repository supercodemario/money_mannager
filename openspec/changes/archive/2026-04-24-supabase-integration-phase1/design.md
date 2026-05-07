## Context

The Flutter app uses **Drift** for local persistence. **`openspec/specs/family-expense-sync/spec.md`** describes target multi-device behavior but is **deferred**. The product decision is to adopt **Supabase** (PostgreSQL + Auth + RLS) for **phase 1**: a **small household pilot** with minimal operational cost, while keeping **SQL portability** for a later **PHP** API on Postgres.

## Goals / Non-Goals

**Goals:**

- Integrate **Supabase Auth** and **Supabase Flutter** with secure configuration (no committed secrets).
- Define a **minimal Postgres schema** for households/members and at least one synced entity (e.g. expenses) with **RLS** so tenants cannot read each other’s rows.
- Keep the app **usable offline** with **Drift as primary** until the user signs in and sync is enabled; sync reconciliation rules are explicit and testable.
- Use **incremental** sync (cursors / `updated_at`), **idempotent** writes (client-generated IDs where appropriate), and a documented **conflict** stance (e.g. last-write-wins per row with server `updated_at`).
- Maintain a **separate network layer** for remote I/O that is **not wired directly** into feature/UI code; **entity sync** to Supabase is triggered only from **local database change signals** (pending rows / outbox / sync state), not from screens.

**Non-Goals:**

- Full parity with every local table in v1; **scope stays minimal** (pilot entities only).
- Custom **PHP** server in this change (future phase).
- Production hardening beyond pilot scale (usage caps, abuse prevention may be follow-ups).
- Letting **widgets or `features/*` presentation code** import `supabase_flutter` or perform **ad-hoc remote calls** for domain data.

## Network boundary (UI vs DB vs remote)

Feature and UI code talk **only** to **application/repository APIs** that read/write **Drift**. The **network layer** (Supabase PostgREST clients, RPC, etc.) lives in a **dedicated module** (e.g. `lib/data/remote/…` or `lib/sync/remote/…`) with **no imports from `features/`**. Nothing in **`lib/features/**`** should reference the Supabase SDK for **entity sync**.

**When remote calls run**

- **Primary trigger:** the **sync orchestrator** observes **local persistence**: e.g. `watch` queries on rows with `sync_status = pending`, an **outbox** table, or a debounced “dirty” flag set in the same transaction as writes.
- **Secondary triggers:** connectivity restored, periodic timer (long interval), app resume—each still resolves work by **reading DB state** (“what is pending?”), not by UI callbacks.
- **Anti-pattern:** a screen calling “upload this expense” on button tap **directly**; the button **commits to Drift** only; sync follows from persisted state.

**Auth session**

- **Supabase Auth** (sign-in / sign-out / session refresh) is **not** “DB-updated” in the same sense; keep it behind a small **`AuthRemoteGateway`** or **`AuthRepository`** used by a **single** auth flow (not scattered across UI). Optionally refresh tokens on a timer; still **no** feature screen imports `Supabase.instance` for data.

```
┌─────────────┐     write/read      ┌──────────────┐     Drift only      ┌─────────────┐
│  UI /       │ ────────────────▶ │ Repositories │ ────────────────▶   │   Drift DB   │
│  features/  │                   │  (domain)    │                     │  (+ outbox)  │
└─────────────┘                   └──────────────┘                     └──────┬──────┘
                                                                              │ watch / poll pending
                                                                              ▼
                                                                       ┌──────────────┐     sole caller      ┌─────────────────┐
                                                                       │ Sync engine  │ ──────────────────▶ │ Remote layer    │
                                                                       │ orchestrator │                     │ (Supabase APIs) │
                                                                       └──────────────┘                     └─────────────────┘
```

## Decisions

1. **Supabase over Firebase** — **PostgreSQL** + standard migrations align with **future PHP + Postgres**; one relational model end-to-end.
2. **RLS as enforcement for remote reads/writes** — Policies keyed by **`household_id`** (and membership) so the Flutter client uses the **anon key** safely when rules are correct; service role keys stay **server-side only** (future Edge Functions or PHP).
3. **Configuration via environment** — `SUPABASE_URL` and `SUPABASE_ANON_KEY` supplied at build/run time (`--dart-define`, CI secrets, flavors). Documented in README or developer docs, not embedded in source.
4. **Feature gating** — Sync code paths active only when user is **signed in** and optional **feature flag** avoids breaking existing offline-only flows.
5. **Conflict strategy (phase 1)** — **Last-write-wins** using server-maintained `updated_at` and monotonic versioning per row; document that **concurrent edits** to the same expense may lose one edit without merge UI in v1.
6. **Isolated network layer + DB-driven sync** — All **entity** remote calls originate from a **sync orchestrator** that consumes **local DB state** (pending/outbox). **UI never** invokes Supabase for domain replication. A **remote** package/module holds Supabase SDK usage for **data**; **features** depend on repositories only.

**Alternatives considered:**

- **Firestore** — Faster document prototyping; worse path to SQL and PHP backend. Rejected for stated roadmap.
- **Direct Postgres without Supabase** — More ops; Supabase bundles Auth, dashboard, and RLS tooling suitable for pilot.

## Risks / Trade-offs

| Risk | Mitigation |
|------|------------|
| Misconfigured **RLS** exposes data | Start with deny-all; add policies per table; review with Supabase policy tests / SQL checks before pilot. |
| **Egress / quota** on free tier | Batch sync, deltas only, avoid polling full tables. |
| **Dual sources of truth** (Drift + Supabase) | Define merge order: e.g. local queue on failure; on sign-in pull remote; resolve with documented LWW. |
| **Key leakage** in builds | CI lint for secrets; only **anon** key in client docs. |

## Migration Plan

1. Add Supabase project (dev); run SQL migrations for schema + RLS.
2. Land Flutter **bootstrap** + Auth UI shell (sign-in / sign-out) behind flag.
3. Implement **repository sync** for scoped entities; Drift schema extended only if needed for sync metadata (`remote_id`, `sync_status` may already exist on expenses).
4. Pilot with **5–15** users; measure egress and errors; iterate.

**Rollback:** Disable feature flag; app continues **local-only**. No destructive local data deletion on rollback.

## Open Questions

- Exact **entity list** for v1 (expenses only vs. recurring + categories)—confirm with product.
- Whether **invites** to a household use magic links or email only in phase 1.
- **Supabase region** vs. majority user geography (set at project creation).
