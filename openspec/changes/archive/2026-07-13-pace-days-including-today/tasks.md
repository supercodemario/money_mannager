## 1. Calculator and persistence

- [x] 1.1 Add `daysLeftIncludingToday` (`max(0, D − day + 1)`); use it in `paceSnapshotMinor` instead of `daysAfterToday`
- [x] 1.2 Update `ensureTodayPaceSnapshot` to persist the including-today divisor (column may keep old name; document meaning)
- [x] 1.3 Fix last-day behavior: divisor 1 → Pace = leftover, not 0

## 2. Tests and docs

- [x] 2.1 Update unit tests: day 10 of 30 → divisor 21; steady 10/day → Pace 10; last day leftover; reject exclude-today divisor
- [x] 2.2 Update `docs/daily-plan-and-pace.md` implementation note to state code matches include-today formula

## 3. Verify

- [x] 3.1 Walk example: pool 300, 30 days, 10/day × 10 days then day 11 spend 20 → day 12 Pace ≈ 9.47 (`180 ~/ 19`)
- [x] 3.2 Confirm Daily plan still `pool ~/ D` and mid-day Pace lock unchanged
