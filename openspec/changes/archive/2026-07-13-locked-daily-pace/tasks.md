## 1. Data model and calculator

- [x] 1.1 Add Drift `daily_pace_snapshots` table (userId, localDate, paceMinor, poolMinor, spentBeforeTodayMinor, daysAfterToday, createdAtMs) with unique (userId, localDate); bump schemaVersion and migrate
- [x] 1.2 Extend `ExpenseLimitsCalculator` with snapshot write helpers: spent-before-today remaining and pace from `(pool − spentBeforeToday) ~/ daysAfterToday`
- [x] 1.3 Add repository API: ensureTodaySnapshot (insert-if-absent), getByDate, watchByDate, listForMonth/range
- [x] 1.4 Unit tests: write formula excludes today spend; ensure is immutable; last day / overspent-before-today → 0

## 2. Wire ensure into derived limits / Home data

- [x] 2.1 On derived watch (or Home bind path), when income configured, ensure today’s snapshot using current pool and month expenses excluding today
- [x] 2.2 Expose locked `paceMinor` (and today’s spent) to dashboard UI instead of live `paceDailyMinor` for Home Pace display
- [x] 2.3 Keep monthly remaining live; do not rewrite snapshot when month spent updates

## 3. Home UI

- [x] 3.1 Show today’s expense vs locked Pace (paired with Daily plan under remaining as designed)
- [x] 3.2 Over-Pace indication when spentToday > locked Pace without changing Pace value
- [x] 3.3 Placeholders when limits unset or snapshot not yet available

## 4. Month listing alignment

- [x] 4.1 Load month Pace snapshots for listing
- [x] 4.2 Prefer locked Pace as over/under threshold when snapshot exists; else Daily plan

## 5. Verify

- [x] 5.1 Manual: Pace 500, spend over 500 → Pace stays 500 with over indication
- [x] 5.2 Run calculator / repository unit tests
