## Context

- Expenses and recurring sync are **household-scoped** end-to-end; `household_id` is never null for cloud-backed rows.
- Users can belong to **multiple** shared households; the client currently resolves sync household via `ensureHouseholdIfNeeded()` (cached id + revalidation, else **first** `household_members` row), with **no** user preference.
- **Signed-in users with no shared family** hit impossible states (e.g. pre-logout sync throwing when no membership row).
- Product decision: every user receives a **personal (self) household** at **sign-up**, identical storage shape to shared households, with **no** QR, **no** invite, **no** join target.

## Goals / Non-Goals

**Goals:**

- Auto-provision **personal household** at cloud sign-up; **backfill** for existing accounts on next eligible session.
- Persist **default expense household** (personal or any shared household the user belongs to); drive sync orchestration and new expense attribution from this preference.
- **Family list** shows personal household **without** QR/share/invite entrypoints; **scan/join/invite** cannot target personal households (UI + server).
- Align **logout** and **post-login** sync with “always have a resolvable household when signed in.”

**Non-Goals:**

- Per-expense household picker on every transaction (preference-only default unless a future change adds it).
- Changing historical expense `household_id` in bulk when the user switches default (new rows use new default; migration of old rows is out of scope unless explicitly requested).
- Deleting Supabase auth user or full account deletion semantics.

## Decisions

1. **Personal flag on `households` (recommended)**  
   - Add `kind` enum or `is_personal boolean` in Postgres; `personal` households are created by a single **RPC or trigger** on `auth.users` insert / client-called `ensure_personal_household`.  
   - **Rationale:** Server can enforce “no join/invite into personal” in one place; client can hide QR without fragile heuristics.

   **Alternative:** Convention-only (name prefix) — **rejected** (fragile, spoofable).

2. **Default expense household storage**  
   - `SharedPreferences` or dedicated key in `SyncMetadataStore` (e.g. `default_expense_household_id`), validated on read: must be personal id **or** a household id present in `household_members` for current user.  
   - Sync active household for orchestrator: **prefer** default expense id when valid; else personal; else first shared (transitional only during migration).

3. **Sign-up hook**  
   - After successful `signUp` / first session with user id, invoke `ensure_personal_household` RPC **idempotent** (returns existing id if present).  
   - **Rationale:** Guarantees row exists before first expense sync.

4. **Family list UX for personal row**  
   - Same list component; conditional: if `kind == personal`, hide “Show QR”, hide invite-related actions; members screen may show only self (still satisfies “list members”).

5. **Join / invite enforcement**  
   - Client: disable paste/join when target id is personal; hide personal household from QR generation.  
   - Server: `accept_family_invite`, `joinHouseholdAsMember`, `add_household_member_as_owner`, etc. **reject** when target household is personal (except the single-owner bootstrap path). Exact RPC list to be updated in implementation.

6. **Logout sync**  
   - Pre-logout guarded sync runs only when unsynced count implies upload **and** default expense household resolves (post-change, always true for signed-in users with personal household). Retain explicit “logout without sync” on failure.

## Risks / Trade-offs

| Risk | Mitigation |
|------|------------|
| Migration: existing users lack personal household | Idempotent backfill RPC on app launch or first sync when `syncAllowed` |
| Duplicate personal households if RPC not idempotent | Unique partial index or `user_id` link table for “owner’s personal household” |
| User switches default; old local rows still tagged old household | Document: existing rows unchanged; optional future “move” feature |
| Server/client drift if only client hides QR | Mandatory DB flag + RLS/RPC rejects |

## Migration Plan

1. Deploy Supabase migration: `households.kind` (or `is_personal`), RLS/policy updates, `ensure_personal_household` RPC.
2. Backfill script or lazy RPC for all existing `auth.users`.
3. Ship app: call ensure on session; read/write default preference; adjust UI.
4. Rollback: feature-flag client; DB migration rollback only if no reliance on column yet.

## Open Questions

- Exact **display name** for personal household (“Self”, “Personal”, localized string).
- Whether **family details** entry from Settings when only personal exists goes to **family list** or **solo member** screen (likely same list).
- Whether **post-login sync** copy references “personal” explicitly for first-time users.
