## ADDED Requirements

### Requirement: Household join scan and household QR are not on profile details

The system SHALL **not** use the **profile details** screen as a host for **scan-to-join** or **household invite QR** generation. Those primary affordances SHALL be provided from the **family list** feature (and related household flows such as QR share) as implemented.

#### Scenario: Profile details omits QR and scanner

- **WHEN** the user opens the profile details screen from Settings
- **THEN** the screen SHALL not present household join scanning or household invite QR widgets

#### Scenario: Family list retains scan and show QR

- **WHEN** the signed-in user views the family list with the standard household actions enabled
- **THEN** the app SHALL continue to provide scan-to-join and per-household show-QR entrypoints consistent with household-family-details
