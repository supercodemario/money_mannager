## ADDED Requirements

### Requirement: Dashboard limits summary distinguishes remaining vs overspent
The dashboard limits summary MUST distinguish non-exceed and exceed states by labeling the monthly balance row as remaining when under guidance and overspent when above guidance.

#### Scenario: Non-exceed state keeps remaining label
- **WHEN** monthly spent is less than or equal to monthly spendable guidance
- **THEN** the monthly balance row SHALL be labeled as remaining and show the remaining amount

#### Scenario: Exceed state switches to overspent label
- **WHEN** monthly spent is greater than monthly spendable guidance
- **THEN** the monthly balance row SHALL be labeled as overspent and show the absolute exceeded amount

### Requirement: Dashboard guidance messaging includes exceeded percent
The dashboard monthly guidance message MUST include exceeded percent in over-budget state while preserving used-percent messaging in non-exceed state.

#### Scenario: Non-exceed guidance shows used percent
- **WHEN** monthly spent is less than or equal to monthly spendable guidance
- **THEN** the guidance subtitle SHALL show used percentage of monthly spendable guidance

#### Scenario: Exceed guidance shows exceeded percent
- **WHEN** monthly spent is greater than monthly spendable guidance
- **THEN** the guidance subtitle or companion line SHALL include exceeded percentage with explicit positive overage wording
