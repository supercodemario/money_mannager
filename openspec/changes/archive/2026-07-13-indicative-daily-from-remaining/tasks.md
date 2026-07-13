## 1. Calculator and derived model

- [x] 1.1 Update `ExpenseLimitsCalculator` so indicative daily is `max(0, pool − monthSpent) ~/ daysInMonth` (0 when remaining ≤ 0)
- [x] 1.2 Extend `ExpenseLimitsDerived.compute` (or equivalent) to accept current-month spent and set `indicativeDailyMinor` from remaining
- [x] 1.3 Add/update unit tests for paid-spend reducing daily, unpaid reservation without double-count, and overspent → 0 daily

## 2. Repository and UI wiring

- [x] 2.1 Wire `watchDerived` (or equivalent) to current-month expense total for the same scope the dashboard uses
- [x] 2.2 Confirm dashboard monthly spending card and Expense Limits summaries use derived daily (no leftover pool-only daily math)
- [x] 2.3 Manually verify: unpaid recurring reduces daily; after mark-paid, daily stays reduced via spent (no jump back to full pool daily)
