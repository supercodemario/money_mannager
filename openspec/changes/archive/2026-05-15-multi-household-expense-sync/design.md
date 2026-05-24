## Context

- Postgres `expenses` rows require `household_id` and `auth_user_id`. RLS **select** allows any row where `household_id ∈ user_household_ids()`; **insert/update** require `auth_user_id = auth.uid()` and membership in that household.
- The client currently resolves one `sync_household_id` from default expense preference + personal fallback and filters pull/push by that id.
- Local Drift stores `householdId` on expenses (set at write from default family preference). The Daily list does not show family name today.

## Goals / Non-Goals

**Goals:**

- Signed-in user syncs **all expenses from all households they belong to** onto one device (all members’ rows in those households, not only rows they created).
- Push pending local rows each with its own `household_id`; writer is always `auth_user_id = auth.uid()`.
- Daily expense list shows a **family label** (household display name; “Self” for personal kind).
- Default expense household in Preferences **only** chooses `household_id` for **new** expenses; changing it does not re-scope sync.

**Non-Goals:**

- Per-household sync watermarks (one global pull cursor per entity type is acceptable for v1 unless volume requires split).
- Filtering the Daily list by family (future enhancement).
- Changing RLS to user-only reads (would break shared family ledger).
- Bulk-moving historical rows when default family changes.

## Decisions

1. **Pull without household filter**  
   - Client queries `expenses` with incremental `updated_at` only; PostgREST + RLS return rows for **all** member households.  
   - **Alternative:** Client loops `household_id IN (...)` from `household_members` — rejected (redundant with RLS, more round-trips).

2. **Push per row**  
   - `effectiveHouseholdId = row.householdId` (required for cloud rows); fail or skip rows missing `household_id` when `syncAllowed`.  
   - No fallback to a global active household for push.

3. **Drop `sync_household_id` for orchestration**  
   - Remove or stop reading `SyncMetadataStore` sync household key for pull/push. Keep `default_expense_household_id` for create path.  
   - `ensureHouseholdIfNeeded` may remain for **bootstrap** (personal household, validating default preference) but MUST NOT gate sync on a single resolved id.

4. **Family label in Daily list**  
   - Resolve `household_id` → display name via cached map from `HouseholdRemoteGateway` / family list (refresh on sync or screen open). Personal household: label **Self** (reuse `AppStrings.preferencesDefaultHouseholdSelf`).  
   - Show as secondary line or chip on `ExpenseTransactionRow` (alongside existing creator line).

5. **Logout pre-sync**  
   - `canRunHouseholdScopedSync` → rename semantically to `canRunCloudSync` / `syncAllowed` only (session + configured Supabase). Unsynced + signed in → may show pre-logout sync.

6. **Recurring**  
   - Same member-wide pull for `recurring_payments` and `recurring_payment_occurrences`; push with each template’s stored `household_id`.

## Risks / Trade-offs

| Risk | Mitigation |
|------|------------|
| Larger pull payloads for users in many families | Incremental `updated_at` watermark; monitor volume |
| Stale household names in list | Refresh name cache when opening Expenses or after sync |
| Local rows missing `householdId` | Backfill on promote-to-pending from default preference; reject push with clear error |
| Duplicate rows across household switch | Row id is global uuid; LWW merge unchanged |

## Migration Plan

1. Ship client: gateway + orchestrator + logout gate + UI label.  
2. No DB migration if RLS unchanged.  
3. Optional one-time: clear `sync_household_id` from SharedPreferences on upgrade.  
4. Update main specs when archiving.

## Open Questions

- Show family label in **Monthly** view when totals mix households (likely yes for category totals aggregation — may need household breakdown later; v1 Daily only per proposal).
