## ADDED Requirements

### Requirement: Compact Settings Overview Layout
The system SHALL render a compact settings overview on the Settings tab that includes a profile summary/edit section, a two-column card grid, and quick-toggle rows in a vertically scrollable layout.

#### Scenario: Settings screen renders compact structure
- **WHEN** the user opens the Settings tab
- **THEN** the screen shows profile information and edit action, four summary cards in a 2x2 grid, and quick-toggle rows below the grid

### Requirement: Summary Cards and Iconography
The system SHALL display exactly four summary cards (Recurring, Family, Limits, Preferences) and SHALL use app-supported Material icons for each card.

#### Scenario: Card count and labels are correct
- **WHEN** the Settings screen is displayed
- **THEN** the user sees four cards labeled Recurring, Family, Limits, and Preferences

#### Scenario: Icons use app icon set
- **WHEN** the summary cards are rendered
- **THEN** each card icon is sourced from Material `Icons.*` APIs used by the app

### Requirement: Quick Toggles Without Recurring CTA
The system SHALL include Biometric Lock and Push Notifications toggle rows and SHALL NOT show an "Add Recurring Cost" button in this compact settings screen.

#### Scenario: Toggle rows are present
- **WHEN** the Settings screen is displayed
- **THEN** the Biometric Lock row and Push Notifications row are visible with switch controls

#### Scenario: Recurring CTA is absent
- **WHEN** the Settings screen is displayed
- **THEN** no button or call-to-action with "Add Recurring Cost" is shown

### Requirement: Existing Profile Edit Behavior Remains Available
The system SHALL retain display-name editing from the current Settings implementation.

#### Scenario: User updates display name from compact settings
- **WHEN** the user taps Edit in the profile section and saves a valid name
- **THEN** the profile display name is updated via the existing profile service flow
