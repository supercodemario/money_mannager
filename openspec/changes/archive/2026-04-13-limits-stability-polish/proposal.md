## Why

The first release of expense limits works, but three stability/trust gaps remain: month-boundary behavior in derived streams, partially inconsistent home card values (mixed real vs placeholder), and unclear validation/error feedback. Polishing these now reduces user confusion before further UI/design iterations.

## What Changes

- Ensure **derived limits refresh correctly across calendar month boundaries** while the app remains open (no stale current-month key assumptions in long-lived streams).
- Tighten **home dashboard consistency** for limit guidance presentation so values shown in the spending card are coherent with configured limits (or clearly marked unset) instead of mixed static placeholders.
- Improve **limits input validation UX** (field-specific validation messages for income vs savings, clearer handling of empty/unset values).
- Preserve current core behavior: guidance remains non-blocking, recurring deduction still uses **enabled + unpaid** templates.

## Capabilities

### New Capabilities

- _(none)_

### Modified Capabilities

- `expense-limits`: Refine runtime update guarantees (month rollover), validation semantics, and dashboard consumption consistency for indicative values.

## Impact

- `ExpenseLimitsRepository.watchDerived` and related date-key logic.
- `DashboardMonthlySpendingCard` display mapping for limit-derived values.
- `ExpenseLimitsScreen` validation and user feedback copy.
- `AppStrings` additions/changes for field-specific errors and unset-state messaging.
