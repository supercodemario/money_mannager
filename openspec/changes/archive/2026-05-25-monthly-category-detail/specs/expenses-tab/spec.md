## MODIFIED Requirements

### Requirement: Monthly view lists totals grouped by category

In Monthly mode, the system MUST show a list of categories with the total amount spent in the selected month for each category, derived from the locally persisted expenses. Each category row MUST be tappable and SHALL navigate to the **category detail** experience for that category and the currently selected month on the Expenses tab.

#### Scenario: Category totals for a month

- **WHEN** the user views Monthly mode for a month with saved expenses
- **THEN** the Expenses tab SHALL list category totals computed by summing `amount_minor` for that month grouped by `category_id`

#### Scenario: User opens category detail from Monthly row

- **WHEN** the user taps a category total row in Monthly mode
- **THEN** the system SHALL open category detail for that `category_id` and the month selected on the Expenses month stepper
