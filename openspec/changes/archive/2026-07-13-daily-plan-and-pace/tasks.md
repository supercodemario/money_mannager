## 1. Calculator and derived model

- [x] 1.1 Add `dailyPlanMinor` and `paceDailyMinor` helpers (`pool ~/ D`; `remaining ~/ daysAfterToday` with exclude-today rules) in `ExpenseLimitsCalculator`
- [x] 1.2 Extend `ExpenseLimitsDerived` / `watchDerived` to expose Daily plan and Pace / day (replace or stop using single Home `indicativeDailyMinor` for the dual UI)
- [x] 1.3 Update unit tests (including day-10 remaining example and last-day zero pace)

## 2. Home UI

- [x] 2.1 Nest Daily plan | Pace / day under the monthly remaining/overspent block; remove standalone indicative-daily pill beside savings
- [x] 2.2 Add strings for Daily plan and Pace / day; keep savings separate
- [x] 2.3 Make the dual-daily row tappable to open the month day listing route

## 3. Month day listing screen

- [x] 3.1 Add routed screen listing days 1…D with Daily plan and local-day spent totals for the current month
- [x] 3.2 Apply red/green for days ≤ today; neutral styling for future days with zero spent
- [x] 3.3 Align Expense Limits detail daily summary label/value with Daily plan where a single daily is shown

## 4. Verification

- [x] 4.1 Manually verify Home remaining block, pace math after overspend, navigation to listing, and over/under colors
