## 1. Data and migration

- [x] 1.1 Add local persistence for expense limit preferences (income minor, savings minor, exclude-unpaid-recurring bool, timestamps) aligned with design (e.g. new Drift table + schema version bump).
- [x] 1.2 Regenerate Drift / run build_runner; ensure migrations run on existing installs.

## 2. Domain calculation and recurring sum

- [x] 2.1 Implement a pure calculator: spendable pool and indicative daily from income, savings, days-in-month, and optional recurring deduction sum (floor division).
- [x] 2.2 Implement sum of `amount_minor_suggested` for **enabled** recurring templates with **unpaid** occurrence for **current local month** `monthKey` (reuse repository/db patterns from recurring payments).

## 3. Repository / services

- [x] 2.3 Add read/write API for limit preferences (load, save, watch stream for UI).
- [x] 2.4 Compose preferences + recurring sum into derived DTO for the limits screen (and optional dashboard consumer).

## 4. UI

- [x] 4.1 Build **expense limits detail** screen: inputs, toggles, save, derived pool + indicative daily display, guidance copy (non-blocking).
- [x] 4.2 Wire **Settings** Limits `_SettingsGridCard` `onTap` to navigate to the detail screen (same navigation style as Recurring management).
- [x] 4.3 Add `AppStrings` for titles, labels, hints, accessibility, and empty/unset states.

## 5. Optional consumption and verification

- [x] 5.1 (Optional) Replace static home dashboard daily/monthly limit display with derived indicative values when income is set.
- [x] 5.2 Run `dart analyze` on touched paths; sanity-check: toggle exclude recurring with 0/1/n unpaid templates; month boundary; savings edge cases per design.
