## Why

The dashboard currently does not surface key limits details in one place, so users cannot quickly understand current spend progress against their monthly guidance. Adding this summary on the home screen improves at-a-glance financial awareness without requiring navigation to Settings.

## What Changes

- Add a dashboard summary section that shows:
  - monthly total expense (current month spent),
  - remaining monthly amount,
  - current savings set,
  - current daily limit.
- Wire the summary to existing local expense-limits preferences and derived values so it reflects saved data.
- Define fallback behavior when limits are not configured (clear unset placeholders).
- Keep existing limits settings flows unchanged; this is a dashboard presentation enhancement.

## Capabilities

### New Capabilities
None.

### Modified Capabilities
- `expense-limits`: Extend behavior to require limits summary details to be visible on the dashboard home screen using persisted preferences and derived guidance.

## Impact

- Affected code: `lib/features/dashboard/view/dashboard_home_screen.dart` and dashboard widget layer (new or updated card/widget).
- Data dependencies: existing `ExpenseLimitsRepository.watchPreferences` and `watchDerived`, plus existing monthly expense totals source.
- No API/backend changes and no schema migration expected.
