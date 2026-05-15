## Why

Users can already choose currency, language, and number format on **Preferences details**, and values persist per profile, but the rest of the app still treats money as USD in many places (hardcoded `$`, `formatExpenseUsdMinor`, English-only `MaterialApp` locale). Aligning storage with **app-wide** formatting and locale makes preferences trustworthy and avoids mismatched symbols and separators across tabs.

## What Changes

- Keep and clarify the three regional controls on `PreferencesDetailsScreen`: **currency**, **language**, and **number format** (existing persistence via preferences service continues).
- Introduce a single **app-wide** source of truth for regional prefs (loaded after login / bootstrap) so widgets do not rely on local widget state alone.
- Wire **Flutter locale** (`locale`, delegates, optional `supportedLocales`) from the saved language so Material/localizations follow the selection where supported.
- Replace ad hoc USD-only formatting with helpers that use **saved currency** and **number format** (grouping/decimal/separator conventions) for displaying minor-unit amounts across expenses, dashboard, quick add, limits, recurring flows, etc.
- Ensure changing currency in Preferences **invalidates or rebuilds** dependent UI so amounts and symbols update without restart where feasible.

## Capabilities

### New Capabilities

- `regional-preferences`: Defines persisted regional settings (currency code, language code, number format preset), how the app loads them for the signed-in user, how **currency** drives symbol and money formatting app-wide, how **language** drives `Locale`/`MaterialApp`, and how **number format** combines with currency for separators and digit grouping.

### Modified Capabilities

- None (existing specs do not define regional formatting; cross-cutting rules live in the new `regional-preferences` capability).

## Impact

- **UI**: `lib/features/settings/view/preferences_details_screen.dart` (already has three dropdowns; may adjust labels/options or wiring to global state).
- **App shell**: Root `MaterialApp` / bootstrap (e.g. `lib/app/` or main) to apply `Locale` and possibly listen to preference streams or `AppServices`.
- **Shared formatting**: New or extended helpers under `lib/share/` or `lib/core/` for formatting minor units with `intl` / `NumberFormat` using stored prefs; refactor call sites that hardcode `$` or `formatExpenseUsdMinor`.
- **Preferences layer**: Existing `preferences` repository/API (`AppServices.preferences`) — ensure read path is available early enough for first paint after auth.
- **Dependencies**: Likely `intl` (already common in Flutter apps); verify `pubspec.yaml`.
