## Why

Product intent in `docs/daily-plan-and-pace.md` defines Pace as **how much the user can spend today** to stay on track: leftover ÷ **days left including today**. Current code divides by **days after today**, so Pace is slightly high mid-month and becomes **0 on the last day** instead of “spend what’s left today.” Align implementation (and specs) with the documented logic users already validated with examples.

## What Changes

- Change Pace snapshot write formula divisor from `D − dayOfMonth` to `D − dayOfMonth + 1` (days left **including** today).
- On the last day of the month, Pace MUST be `max(0, pool − spentBeforeToday)` (divisor 1), not zero.
- Keep: leftover = pool − spent before today; write-once per day; no mid-day live rewrite; Daily plan unchanged (`pool ÷ D`).
- Update OpenSpec expense-limits / daily-pace-history wording and unit tests to match.
- Update `docs/daily-plan-and-pace.md` implementation note to state code is aligned (remove “gap” wording after apply).

## Capabilities

### New Capabilities

- (none)

### Modified Capabilities

- `expense-limits`: Pace snapshot write / Home locked Pace uses days left **including** today; last-day behavior.
- `daily-pace-history`: Stored `daysAfterToday` field semantics → store days-left-including-today (rename in code/schema if practical, or document column meaning update).

## Impact

- `ExpenseLimitsCalculator.daysAfterToday` / new helper + `paceSnapshotMinor`
- `ExpenseLimitsRepository.ensureTodayPaceSnapshot` and derived compute
- Drift column may remain named `days_after_today` with new meaning, or rename in a migration
- Tests in `expense_limits_calculator_test.dart`, `daily_pace_snapshot_test.dart`
- Existing Pace snapshot rows for “today” stay immutable (old formula); new days and new installs get new formula—acceptable

## Current vs target (check)

| | Current code | Target (`docs/daily-plan-and-pace.md`) |
|--|--------------|----------------------------------------|
| Daily plan | `pool ÷ D` | Same |
| Leftover | `pool − spent before today` | Same |
| Divisor | `D − day` (exclude today) | `D − day + 1` (include today) |
| Day 13 of 31 | ÷ 18 | ÷ 19 |
| Last day | Pace = 0 | Pace = leftover |
| Locked mid-day | Yes | Yes |
| Over-pace UI | Yes | Yes |

Example (pool 300, 30-day month, spend 10/day for 10 days, day 11 spend 20 → day 12 Pace):

- Current: `180 ÷ 18 = 10`
- Target: `180 ÷ 19 ≈ 9.47` (matches the worked example)
