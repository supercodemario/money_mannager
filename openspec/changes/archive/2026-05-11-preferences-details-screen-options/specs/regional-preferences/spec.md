# regional-preferences (delta)

## ADDED Requirements

### Requirement: Regional preferences are loaded for the signed-in user

The system SHALL load the current user’s saved `currencyCode`, `languageCode`, and `numberFormat` from persistent storage for the **active** user profile and SHALL make that snapshot available to the UI layer for locale and formatting.

#### Scenario: Defaults when no row exists

- **WHEN** no `userPreferences` row exists for the current user
- **THEN** the system SHALL use documented defaults (e.g. `USD`, `en`, `us`) for formatting and locale until a row is created

### Requirement: Application locale follows saved language

The system SHALL derive `Locale` for the root `MaterialApp` (or equivalent app root) from the saved `languageCode` so that locale-aware APIs (dates, numbers where delegated to Flutter) align with the user’s language selection where supported.

#### Scenario: Language change applies without restart

- **WHEN** the user changes the language in Preferences and preferences are persisted
- **THEN** the app SHALL rebuild or otherwise apply the new `Locale` without requiring the user to restart the application

### Requirement: Monetary display uses saved currency and number format

The system SHALL format integer minor-unit amounts for **display** using the saved `currencyCode` and `numberFormat` (including appropriate currency symbol or code and grouping/decimal separators). Screens that show expense totals, dashboard amounts, limits, and recurring amounts SHALL use this shared behavior instead of hardcoding a single currency.

#### Scenario: Currency change updates visible amounts

- **WHEN** the user changes currency in Preferences and preferences are persisted
- **THEN** all screens that display monetary amounts using the shared formatting path SHALL show the new currency symbol or formatting convention without requiring an application restart

### Requirement: Preference changes propagate app-wide

The system SHALL observe changes to the user’s regional preference row (including updates from `PreferencesDetailsScreen`) and SHALL notify dependent widgets so that formatting and locale updates take effect across tabs and navigators without restarting the process.

#### Scenario: Stream or equivalent subscription

- **WHEN** regional preferences are updated in the database for the current user
- **THEN** widgets that depend on regional formatting SHALL receive an update and re-render with the new preferences
