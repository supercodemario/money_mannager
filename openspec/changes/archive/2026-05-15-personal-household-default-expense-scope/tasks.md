## 1. Database (Supabase)

- [x] 1.1 Add `households` column or enum for personal vs shared (e.g. `kind` / `is_personal`) plus migration notes in `supabase/migrations/`
- [x] 1.2 Add idempotent RPC `ensure_personal_household` (create personal household + owner membership if missing; return id)
- [x] 1.3 Tighten RLS / RPCs: reject join, invite accept, add-member paths that target personal households (except owner bootstrap)
- [x] 1.4 Backfill existing `auth.users` with personal households (one-time migration or lazy client invoke; document choice)

## 2. Client bootstrap and session

- [x] 2.1 Call `ensure_personal_household` after successful sign-up and on sign-in when session present and personal row missing
- [x] 2.2 Persist **default expense household id** (extend `SyncMetadataStore` or equivalent); validate against memberships + personal id on read/write
- [x] 2.3 Replace `ensureHouseholdIfNeeded` logic with preference-first + personal fallback (remove arbitrary `LIMIT 1` when preference valid)

## 3. Sync orchestrator and logout

- [x] 3.1 Use resolved default expense `household_id` for all household-scoped push/pull in `SyncOrchestrator`
- [x] 3.2 Update `signOutWithSyncBeforeLogout` / `ManualSyncHelper`: only show pre-logout sync when upload can run (per delta spec)
- [x] 3.3 Adjust post-login bootstrap if needed so personal household exists before first household-scoped sync

## 4. Preferences UI

- [x] 4.1 Add default expense household selector to preferences details (personal + shared list; labels per design)
- [x] 4.2 Persist selection and notify cloud sync / orchestration consumers (e.g. listener or `CloudSyncController`)

## 5. Family list, members, flows

- [x] 5.1 Plumb `household.kind` (or equivalent) to family list repository/models
- [x] 5.2 Hide **Show QR** / share / invite entry points for personal household rows
- [x] 5.3 Hide add-member scan on members screen for personal household
- [x] 5.4 Block scan/paste/join/invite confirm when target resolves to personal household (client); rely on server errors as defense in depth

## 6. Expense creation

- [x] 6.1 Attach new expenses (and recurring if applicable) to **default expense household** at write time when signed in and cloud path applies
- [x] 6.2 Document behavior for existing rows when user changes default (no bulk move unless product adds it)

## 7. Tests and verification

- [x] 7.1 Widget or integration tests: preferences default selection persistence
- [x] 7.2 Tests or manual script: logout with unsynced + personal household does not throw “household not available”
- [x] 7.3 Verify OpenSpec deltas by scenario walkthrough (family list QR hidden for personal; join rejected)
