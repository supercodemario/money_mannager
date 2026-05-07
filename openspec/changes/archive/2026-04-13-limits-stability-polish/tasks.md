## 1. Month rollover correctness

- [x] 1.1 Update `ExpenseLimitsRepository.watchDerived` so recurring deduction and day-count react correctly when the local month changes while app remains open.
- [x] 1.2 Add or update tests (or deterministic checks) for month boundary behavior (e.g., Jan→Feb and leap-year handling).

## 2. Validation clarity

- [x] 2.1 Introduce field-specific validation messages/strings for invalid income and invalid savings input.
- [x] 2.2 Update `ExpenseLimitsScreen` validation flow to use specific messages while preserving empty-as-clear behavior.

## 3. Dashboard consistency

- [x] 3.1 Update `DashboardMonthlySpendingCard` daily guidance rendering to be consistently derived when income exists and clearly unset when not configured.
- [x] 3.2 Remove or re-label any misleading static daily guidance representation tied to limits in the same card.

## 4. Verification

- [x] 4.1 Run `dart analyze` on touched files.
- [x] 4.2 Sanity-check: keep app open across month boundary simulation, invalid income/savings errors, and dashboard unset/set states.
