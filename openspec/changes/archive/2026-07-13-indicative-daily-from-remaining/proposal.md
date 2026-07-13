## Why

Indicative daily is currently `spendablePool ÷ daysInMonth`. When a recurring bill is marked paid, it leaves the unpaid reservation **R**, so the pool (and daily) jump back up even though that money is already spent. Users can then treat daily as free-to-spend and end the month short by the paid bill amounts. Daily guidance should reflect money already gone from salary.

## What Changes

- **BREAKING** (guidance math): Derive **indicative daily** from **remaining monthly guidance** (spendable pool minus current-month spent), not from the raw spendable pool alone.
- Keep existing spendable-pool rules (income − savings − optional unpaid recurring reservation).
- Keep remaining / overspent dashboard semantics aligned with the same remaining value used for daily.
- Guidance remains non-blocking (does not prevent recording expenses).

## Capabilities

### New Capabilities

- (none)

### Modified Capabilities

- `expense-limits`: Change how indicative daily is derived so paid spending (including paid recurrings recorded as expenses) reduces daily guidance; clarify relationship between pool, remaining, and daily.

## Impact

- `ExpenseLimitsCalculator` / `ExpenseLimitsDerived` (and/or dashboard derivation) — daily formula
- `ExpenseLimitsRepository.watchDerived` (or dashboard card) — needs current-month spent in the derivation path
- Dashboard monthly spending / limits summary UI and Expense Limits detail summaries
- Unit tests for expense-limits calculator / repository / dashboard guidance
