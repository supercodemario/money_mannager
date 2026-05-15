## MODIFIED Requirements

### Requirement: Compact Settings Overview Layout

The system SHALL render a compact settings overview on the Settings tab that includes a profile summary section (navigation into profile details), a two-column card grid, and quick-toggle rows in a vertically scrollable layout. The compact Settings overview SHALL **not** include a **standalone cloud sync account card** on this screen; cloud sync sign-in and manage-account affordances SHALL be provided from **profile details** instead.

#### Scenario: Settings screen renders compact structure

- **WHEN** the user opens the Settings tab
- **THEN** the screen shows profile summary information with navigation into profile details, four summary cards in a 2x2 grid, and quick-toggle rows below the grid, and **does not** show the standalone cloud sync section that was relocated to profile details

### Requirement: Profile summary opens profile details for family invite QR

The system SHALL navigate to the **profile details** screen when the user activates the **profile summary** section on the compact Settings overview.

#### Scenario: Profile section navigates to profile details

- **WHEN** the user activates the profile summary area on the Settings tab (per implementation: card tap or explicit control)
- **THEN** the app SHALL present the profile details screen that satisfies the `profile-details-family-invite` capability (identity, cloud sync account, and account actions per that capability’s requirements)
