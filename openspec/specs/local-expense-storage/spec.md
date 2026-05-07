## ADDED Requirements

### Requirement: Expenses are persisted locally in SQLite via Drift

The system MUST store expense records on device using a SQLite database accessed through **Drift**, with schema versioned via Drift migrations. No remote API SHALL be required for read or write in this capability.

#### Scenario: Offline persistence

- **WHEN** the app runs without network connectivity
- **THEN** the system SHALL still be able to insert and read expense records from local storage

### Requirement: Expense rows use a stable schema including creator attribution

Each persisted expense MUST include:

- A unique primary key `id` of type TEXT (UUID)
- `amount_minor` as INTEGER (minor units, e.g. cents)
- `currency_code` as TEXT (application default allowed)
- `category_id` as TEXT (references the app’s category catalog identifiers)
- `note` as optional TEXT
- `occurred_at` as INTEGER (transaction date/time in UTC epoch milliseconds)
- `created_at` and `updated_at` as INTEGER (UTC epoch milliseconds)
- `created_by_user_id` as TEXT NOT NULL (references the persisted user profile row for the member who created the expense)
- Optional nullable `recurring_payment_id` as TEXT (references the recurring payment template id when the expense was created from the fulfill recurring payment flow)

#### Scenario: Insert supplies required fields

- **WHEN** a new expense is saved
- **THEN** the system SHALL persist a row with all required fields populated and timestamps set appropriately, including `created_by_user_id` matching the active local user, and `recurring_payment_id` set when the expense fulfills a recurring payment otherwise NULL

### Requirement: Feature code uses a repository boundary

Application features MUST NOT embed Drift table or query details directly in UI widgets. Data access SHALL go through a dedicated abstraction (e.g. repository or local data source) that wraps the Drift database.

#### Scenario: UI does not import generated Drift implementation details

- **WHEN** a feature screen performs a save or load operation
- **THEN** it SHALL call the repository (or equivalent) rather than opening SQL or Drift APIs directly from the widget layer

### Requirement: Saving from Quick Add persists an expense

When the user completes the Quick Add flow with a valid positive amount and a selected category and triggers the save affordance, the system MUST insert a persisted expense row consistent with the schema above (including date, note, category id, amount, and creator user id).

#### Scenario: Successful save creates a row

- **WHEN** the user saves a valid expense from Quick Add
- **THEN** a new expense row SHALL exist in local storage with values matching the user’s entered amount, date, note, category, and the current user as creator

### Requirement: API and sync are out of scope

This capability MUST NOT depend on HTTP clients, remote authentication, or background sync workers. Such integration SHALL be introduced in a separate change.

#### Scenario: No network for core persistence

- **WHEN** evaluating whether local save succeeds
- **THEN** success SHALL not require outbound network calls
