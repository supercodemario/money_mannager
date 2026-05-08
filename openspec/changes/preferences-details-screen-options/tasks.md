## 1. Regional formatting scope and app root

- [x] 1.1 Add an `InheritedWidget` (or equivalent) under `AppServices` / above `MaterialApp` content that exposes resolved `Locale`, currency formatting for minor units, and helpers derived from the latest `UserPreference` row (with defaults when null).
- [x] 1.2 Resolve `userId` via `UserProfileRepository.getCurrentUserId()` and subscribe to `UserPreferencesRepository.watchForUser(userId)`; rebuild the subtree when preferences change.
- [x] 1.3 Pass `locale` (from saved `languageCode`) into `MaterialApp` and set `supportedLocales` / `localizationsDelegates` as needed for chosen languages.

## 2. Shared formatting utilities

- [x] 2.1 Implement mapping from `numberFormat` preset (`us`, `eu`, `in`) plus `currencyCode` + `Locale` to `NumberFormat` (or composed patterns) for displaying integer minor units as currency strings.
- [x] 2.2 Replace or extend `formatExpenseUsdMinor` / parsing helpers in `expenses_amount_format.dart` (or move to `share/`) so entry fields and displays use the active preset for separators where applicable.

## 3. Migrate UI call sites

- [x] 3.1 Replace hardcoded `$` / USD-only formatting in expense flows (`add_expense_screen`, `quick_add_screen`, list rows, recurring sheets, expense limits previews, dashboard cards, etc.) with the regional scope helpers.
- [x] 3.2 Verify `PreferencesDetailsScreen` saves via existing `upsertForUser` and that changing each dropdown triggers the watch so other tabs update without restart.

## 4. Verification

- [ ] 4.1 Manual pass: set currency to EUR and INR; confirm symbols and grouping change on Dashboard, Expenses, Quick Add, and Limits.
- [ ] 4.2 Manual pass: change language and confirm `MaterialApp` locale updates (dates/numbers as visible) without restart.
- [x] 4.3 Run existing widget/tests; fix failures from constructor or context assumptions.
