# expenses-tab (delta)

## ADDED Requirements

### Requirement: Daily expense rows show family attribution

In **Daily** mode, each expense row in the transaction list SHALL display which **household (family)** the expense belongs to, using the household’s display name from cloud metadata when available. For the user’s **personal** household, the label SHALL use the same product string as preferences (e.g. **Self expense**). The label SHALL be visible whenever the expense has a `household_id` (including when the user belongs to multiple families and the list merges expenses from more than one household).

#### Scenario: Multi-family user sees family name per row

- **WHEN** the user views Daily mode and local data includes expenses from more than one household
- **THEN** each row SHALL show a family label distinguishing which household the expense belongs to

#### Scenario: Personal household uses Self label

- **WHEN** an expense row’s household is the user’s personal household
- **THEN** the row SHALL show the personal household label (e.g. Self expense) rather than a generic household name when applicable

#### Scenario: Single household still shows label

- **WHEN** the user belongs to only one household and views Daily mode
- **THEN** rows SHALL still show the family label for consistency
