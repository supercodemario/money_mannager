# settings-compact-screen (delta)

## ADDED Requirements

### Requirement: Profile summary opens profile details for family invite QR

The system SHALL navigate to the **profile details** screen when the user activates the **profile summary** section on the compact Settings overview. Display-name editing SHALL remain available from the **profile details** screen.

#### Scenario: Profile section navigates to profile details

- **WHEN** the user activates the profile summary area on the Settings tab (per implementation: card tap or explicit control)
- **THEN** the app SHALL present the profile details screen that satisfies the `profile-details-family-invite` capability

#### Scenario: Display-name edit from profile details

- **WHEN** the user opens profile details from Settings and uses the Edit affordance for display name on that screen
- **THEN** the system SHALL update the profile display name via the existing profile service flow
