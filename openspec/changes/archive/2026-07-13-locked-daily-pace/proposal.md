## Why

Live **Pace / day** on Home recalculates whenever today’s spending changes. After overspending a starting Pace (e.g. 500 → 200), users read the new number as a fresh daily allowance and feel they can spend again—undermining the app’s keep-in-budget goal. Pace must be a **stable daily target**, with exceed indicated separately, and each day’s Pace stored for analytics and charts.

## What Changes

- Persist one **immutable Pace snapshot per local calendar day** (and user/scope) in local DB when the day is first ensured.
- Compute that snapshot using remaining **excluding today’s spend**, divided by **days after today** (today excluded from the divisor).
- On Home, show a **daily expense / Pace** presentation: today’s spent vs the locked Pace for today—**no live Pace updates** mid-day.
- When today’s spend exceeds locked Pace, show a clear **over-Pace** indication (amount and/or styling) without rewriting Pace.
- Replace the live `paceDailyMinor` used on Home with the locked daily row (live formula may remain only as the writer for new day rows).
- Keep **Daily plan** (`pool ~/ D`) as the fixed month plan; it is unchanged in meaning.
- Store enough history fields for future graphs (at least date, pace minor, and snapshot inputs used at write time).

## Capabilities

### New Capabilities

- `daily-pace-history`: Persist and read per-day Pace snapshots for Home, analytics, and future graphical representation; write-once per local day.

### Modified Capabilities

- `expense-limits`: Home Pace presentation becomes the locked daily Pace (not live remaining÷days); over-Pace indication vs today’s spend; clarify that live recalculation MUST NOT update the displayed Pace for the current day.
- `month-day-spend-listing`: Optional alignment so day rows can use locked Pace for that date when a snapshot exists (for consistent over/under vs Home); otherwise keep Daily plan comparison as today.

## Impact

- Drift schema + migration: new daily pace history table.
- `ExpenseLimitsCalculator` / repository: ensure-day write path; Home reads locked Pace + today’s spent.
- Dashboard Home UI (`dashboard_home_expense_body` / monthly spending card or new card): daily expense vs locked Pace + exceed state.
- Tests for write-once, exclude-today math at snapshot time, and over-Pace UI logic.
- Cloud sync of pace history is **out of scope** for this change (local-only history unless a follow-up adds it).
