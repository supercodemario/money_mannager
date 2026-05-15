# settings-compact-screen (delta)

## ADDED Requirements

### Requirement: Family summary card opens family details when available

The system SHALL navigate to the **family details** screen (household member list and owner-gated actions per `household-family-details`) when the user activates the **Family** summary card on the compact Settings overview, subject to session and household readiness rules defined in that capability.

#### Scenario: Tap Family card opens family details when eligible

- **WHEN** the user taps the Family summary card on the Settings tab and the user is eligible per `household-family-details`
- **THEN** the app SHALL present the family details experience

#### Scenario: Ineligible user receives appropriate UX

- **WHEN** the user taps the Family summary card but is not eligible (e.g. not signed in)
- **THEN** the app SHALL present sign-in guidance, a blocking screen, or equivalent behavior consistent with `household-family-details` and SHALL NOT silently fail
