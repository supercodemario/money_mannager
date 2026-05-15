## Why

Sync currently pulls and pushes expenses for **one** “active” household (default expense preference). Users in multiple families only see one household’s cloud data per cycle, while RLS already allows reading **all** households they belong to. Bob in three families should get **every** member’s expenses from all three households on his phone, with each row still tagged by `household_id` at create time.

## What Changes

- **Pull**: Fetch expenses (and recurring entities) for **all** households the user is a member of—rely on RLS `user_household_ids()` (no client `.eq('household_id', activeId)` filter).
- **Push**: Upload each pending row with its **stored** `household_id` and `auth_user_id` = signed-in user (no single-household orchestrator scope).
- **Remove** using `sync_household_id` / default preference as the **sync boundary** (preference remains for **new expense attribution** only).
- **Expenses tab (Daily list)**: Show a **family label** on each row so users can tell which household an expense belongs to when multiple families are merged locally.
- **Logout / manual sync gates**: Run when signed in and sync is allowed, not when a single household id resolves.

## Capabilities

### New Capabilities

_(none — behavior extends existing sync and expenses UI)_

### Modified Capabilities

- `supabase-phase1-sync`: Replace single-household sync scope with member-wide pull; per-row `household_id` on push; update logout/pre-sync gates.
- `personal-household-expense-scope`: Clarify default expense household is for **new row attribution** only, not sync filter.
- `expenses-tab`: Daily expense rows SHALL show which family (household) each expense belongs to.
- `recurring-payments-sync`: Align recurring template/occurrence pull/push with member-wide scope (if currently single-household).

## Impact

- **Flutter**: `SyncOrchestrator`, `ExpenseRemoteGateway`, `RecurringRemoteGateway`, `CloudSyncController.ensureHouseholdIfNeeded` usage, `ManualSyncHelper`, `SyncMetadataStore` keys, `ExpenseTransactionRow` / repository joins for household display names.
- **Supabase**: Likely **no schema change**; confirm RLS select policies already scope by membership.
- **UX**: Merged multi-family ledger on device; family name visible per row in Daily view.
