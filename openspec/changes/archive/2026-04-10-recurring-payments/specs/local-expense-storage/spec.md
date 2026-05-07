## MODIFIED Requirements

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
