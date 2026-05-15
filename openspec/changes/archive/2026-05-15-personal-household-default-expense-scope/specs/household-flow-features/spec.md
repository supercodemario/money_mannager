# household-flow-features (delta)

## ADDED Requirements

### Requirement: Primary household surfaces respect personal household restrictions

Feature modules under **household-flow-features** SHALL enforce the same personal-household rules as **household-family-details**: no **show QR** for personal households; **scan-to-join**, **paste id join**, and **invite confirm** flows SHALL reject or block targets that resolve to a personal household; navigation contracts SHALL not construct QR share routes for personal household ids.

#### Scenario: Family list omits show QR for personal household

- **WHEN** the signed-in user views the `family_list` feature and a personal household row is present
- **THEN** show-QR (or equivalent) SHALL NOT be invoked for that row

#### Scenario: Scan flow cannot join a personal household

- **WHEN** the user completes scan or paste of an id that identifies a personal household
- **THEN** the app SHALL not complete a join that adds the user to that household (and SHALL show an explicit outcome)

