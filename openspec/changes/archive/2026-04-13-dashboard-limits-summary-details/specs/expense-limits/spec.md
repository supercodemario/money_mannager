## ADDED Requirements

### Requirement: Dashboard home shows limits summary details
The system MUST show a limits summary section on dashboard home that includes monthly total expense, remaining monthly amount, current savings set, and current daily limit using locally persisted preferences and derived guidance values.

#### Scenario: Dashboard renders all requested details
- **WHEN** the user opens dashboard home
- **THEN** the limits summary SHALL display monthly total expense, remaining monthly amount, current savings set, and current daily limit

#### Scenario: Remaining monthly amount is derived from guidance and spending
- **WHEN** monthly total expense and spendable monthly guidance are available
- **THEN** remaining monthly amount SHALL be derived from those values (not a separately persisted field)

#### Scenario: Unset limits show explicit placeholders
- **WHEN** income/savings/limits are not configured
- **THEN** the corresponding limits summary fields SHALL show explicit unset placeholders rather than misleading numeric values
