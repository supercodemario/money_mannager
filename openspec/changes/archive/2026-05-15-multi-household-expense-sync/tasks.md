## 1. Remote gateways

- [x] 1.1 `ExpenseRemoteGateway`: remove `householdId` filter on `fetchExpensesSince` / `countExpenses` (RLS-only scope); keep `household_id` on upsert from row
- [x] 1.2 `RecurringRemoteGateway`: same member-wide pull; per-row `household_id` on upsert
- [x] 1.3 Document that server RLS `expenses_select_member` enforces membership (no migration unless gap found)

## 2. Sync orchestrator and metadata

- [x] 2.1 `SyncOrchestrator`: stop resolving single `hid` for pull; push expenses/recurring with `row.householdId` only (handle null household on pending rows)
- [x] 2.2 Remove or deprecate `sync_household_id` usage for orchestration; keep `default_expense_household_id` for create path only
- [x] 2.3 `CloudSyncController.ensureHouseholdIfNeeded`: limit to preference/personal bootstrap, not sync gate
- [x] 2.4 `ManualSyncHelper.canRunHouseholdScopedSync` → gate on `syncAllowed` / session only; update logout flow and tests
- [x] 2.5 `getRemoteExpenseCount`: count across all member households (RLS-scoped query)

## 3. Expense list family label

- [x] 3.1 Cache household id → display name (and personal kind) for signed-in user; refresh on Expenses tab open or after sync
- [x] 3.2 Extend `ExpenseWithCreator` or row model with `householdDisplayLabel`
- [x] 3.3 `ExpenseTransactionRow`: show family label (Self for personal)
- [x] 3.4 `AppStrings` for family label on expense row if needed

## 4. Tests and docs

- [x] 4.1 Unit tests: orchestrator/gateway pull without household filter; push uses row household
- [x] 4.2 Update `account_session_flow_logout_test` / `manual_sync_helper` tests for new gate
- [x] 4.3 Widget or unit test: expense row shows family label when multiple households
- [x] 4.4 Update `docs/backend-developer-overview.md` sync section
