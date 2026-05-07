## ADDED Requirements

### Requirement: Preferences summary card opens preferences details screen
The system SHALL navigate to a dedicated preferences details screen when the user taps the Preferences summary card on compact Settings.

#### Scenario: Tap Preferences card opens details screen
- **WHEN** the user taps the Preferences card in Settings
- **THEN** the app SHALL present a preferences details screen

### Requirement: Preferences details screen includes regional preferences and category listing entry
The preferences details screen MUST include settings for Currency, Language, and Number Format, and MUST provide an entry point to category listing management.

#### Scenario: Regional preferences are visible
- **WHEN** the user opens preferences details
- **THEN** the screen SHALL show Currency, Language, and Number Format controls

#### Scenario: Category listing entry is accessible
- **WHEN** the user is on preferences details
- **THEN** the screen SHALL provide navigation to category listing management
