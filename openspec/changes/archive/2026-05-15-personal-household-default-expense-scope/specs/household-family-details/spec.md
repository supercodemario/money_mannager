# household-family-details (delta)

## ADDED Requirements

### Requirement: Personal household omits collaboration affordances

When the active household is the user’s **personal** household, the family details and family list surfaces SHALL NOT present **household QR share**, **add member via QR scan**, **invite**, or other entry points whose purpose is to add or onboard additional members to that household.

#### Scenario: Personal household row has no show QR

- **WHEN** the user views a list of households that includes their personal household
- **THEN** the app SHALL NOT offer per-household QR or share-id actions for the personal household row

#### Scenario: Personal household members screen does not offer owner scan-to-add

- **WHEN** the user opens members or family details for their personal household
- **THEN** the app SHALL NOT show the add-member QR scan affordance used for shared households

### Requirement: Signed-in user with only personal household still reaches family experience

When the user is signed in and has a personal household but **no** shared households (or chooses to view family), the app SHALL still allow navigation to the family list or equivalent experience without treating “no shared family” as an unsigned or error state solely for that reason.

#### Scenario: Family entry from Settings when only personal exists

- **WHEN** the user taps the Family entry from compact Settings and has only a personal household
- **THEN** the app SHALL present the family list (or equivalent) showing the personal household row and applicable shared rows, not a blocking “household not ready” error solely due to lack of shared households
