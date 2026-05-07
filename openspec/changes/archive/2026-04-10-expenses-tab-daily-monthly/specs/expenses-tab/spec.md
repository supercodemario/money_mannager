## ADDED Requirements

### Requirement: Expenses tab shows a Daily and Monthly switch

The system MUST provide an Expenses tab screen that allows the user to switch between **Daily** and **Monthly** views of expenses.

#### Scenario: User switches view mode

- **WHEN** the user selects Daily or Monthly in the Expenses tab
- **THEN** the Expenses tab SHALL update to show the corresponding view

### Requirement: Daily view lists expenses grouped by day

In Daily mode, the system MUST show a list of expense entries grouped by local calendar day, ordered with the most recent day first and the most recent expense first within each day.

#### Scenario: Daily list groups by calendar day

- **WHEN** expenses exist across multiple calendar days
- **THEN** the Expenses tab SHALL group them by day headings (e.g. Today / date label) and display items under the correct day

### Requirement: Monthly view lists totals grouped by category

In Monthly mode, the system MUST show a list of categories with the total amount spent in the selected month for each category, derived from the locally persisted expenses.

#### Scenario: Category totals for a month

- **WHEN** the user views Monthly mode for a month with saved expenses
- **THEN** the Expenses tab SHALL list category totals computed by summing `amount_minor` for that month grouped by `category_id`

### Requirement: Expenses data is fetched from local storage

Both Daily and Monthly views MUST read expenses from the local Drift/SQLite database via repository methods (not hardcoded sample data).

#### Scenario: Recent save appears in Expenses tab

- **WHEN** the user saves an expense in Quick Add
- **THEN** the saved expense SHALL be retrievable from local storage and MAY appear in the Daily or Monthly Expenses view without restarting the app

