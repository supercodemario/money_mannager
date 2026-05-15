# profile-details-family-invite (delta)

## ADDED Requirements

### Requirement: Profile details screen shows identity and family-invite QR

The system SHALL provide a **profile details** screen that displays the current user’s **display name** (from the persisted user profile) and a **QR code** suitable for **family invite**: another party scans the code during the app’s add-to-family flow to capture the invitee’s identifier.

#### Scenario: Display name is visible

- **WHEN** the user opens the profile details screen and a user profile exists
- **THEN** the screen SHALL show that profile’s display name

#### Scenario: QR encodes profile id for family invite

- **WHEN** the profile details screen is shown and the current profile has id `id`
- **THEN** the QR code SHALL encode exactly the string value of `id` (UTF-8) for use as the family-invite payload in scanning flows

### Requirement: Profile details explains family-invite use

The profile details screen SHALL include concise copy that the QR is for **adding this member to a family** (or equivalent product wording), so users do not mistake it for a generic account identifier.

#### Scenario: Helper text is shown

- **WHEN** the user views the profile details screen
- **THEN** the screen SHALL show explanatory text linking the QR to family invite / scan-to-add behavior
