## Why

Home dashboard amounts (family budget, spending, savings, remaining) are visible at a glance, which is awkward when someone else can see the phone. Users need a persistent privacy preference that masks those amounts by default, with a short-lived peek on Home only.

## What Changes

- Add a **Privacy mode** switch on the Settings screen that persists on-device via SharedPreferences.
- When Privacy mode is on, mask exactly four Home amounts as `{currencySymbol} •••••`:
  - Total family budget
  - Monthly spending (spent amount)
  - Monthly savings
  - Monthly remaining
- When Privacy mode is on, show an eye icon beside Total family budget. Tapping it temporarily reveals all four amounts on Home.
- Temporary reveal never updates the Settings switch; peek clears when leaving Home or when the app backgrounds.
- When Privacy mode is off, amounts show normally and the eye icon is hidden.
- Other Home content (indicative daily, progress %, subtitles, upcoming bills, etc.) stays unmasked.

## Capabilities

### New Capabilities
- `dashboard-privacy-mode`: Device-local privacy preference, masked Home amounts, and Home-only temporary reveal with auto-hide.

### Modified Capabilities
- (none)

## Impact

- **UI**: `settings_screen.dart` (new switch); `dashboard_budget_hero.dart` / `dashboard_monthly_spending_card.dart` / Home body (mask + eye + reveal lifecycle).
- **Persistence**: New SharedPreferences helper (same pattern as `OnboardingPreferences`); not Drift, not cloud sync.
- **State**: Persistent `privacyEnabled` readable from Settings and Home; ephemeral `_temporarilyRevealed` owned only by Home.
- **Strings / tokens**: New Settings and accessibility labels in `AppStrings`.
