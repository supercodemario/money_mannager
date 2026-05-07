## ADDED Requirements

### Requirement: Home monthly spending indicates over-budget state
The system MUST present an explicit over-budget state on the Home monthly spending summary when monthly spent exceeds monthly spendable guidance.

#### Scenario: Over-budget state activates when spent exceeds guidance
- **WHEN** monthly spent is greater than monthly spendable guidance
- **THEN** the monthly spending card SHALL render an over-budget warning state instead of on-track state

### Requirement: Over-budget state communicates exceeded amount and percent
In over-budget state, the system MUST show the exceeded amount and exceeded percentage, and MUST style exceed indicators with warning color semantics.

#### Scenario: Exceeded metrics are shown in over-budget state
- **WHEN** the monthly spending card is in over-budget state
- **THEN** it SHALL show exceeded amount and exceeded percent in the card content

#### Scenario: Over-budget visuals use warning treatment
- **WHEN** the monthly spending card is in over-budget state
- **THEN** the monthly spending value, progress indicator, and overage labels SHALL use warning (red) styling
