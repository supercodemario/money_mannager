# dashboard-privacy-mode Specification

## Purpose

Let users hide key Home dashboard amounts behind a persisted Privacy mode preference, with a Home-only temporary reveal that does not change Settings.

## Requirements

### Requirement: Privacy mode preference on Settings

The system SHALL provide a Privacy mode switch on the Settings screen whose on/off value is persisted in SharedPreferences on the device. Temporary reveal on Home MUST NOT change this persisted value or the Settings switch state.

#### Scenario: Enable privacy mode

- **WHEN** the user turns Privacy mode on in Settings
- **THEN** the preference is saved to SharedPreferences as enabled
- **AND** the Settings switch remains on

#### Scenario: Disable privacy mode

- **WHEN** the user turns Privacy mode off in Settings
- **THEN** the preference is saved to SharedPreferences as disabled
- **AND** the Settings switch remains off

#### Scenario: Preference survives restart

- **WHEN** Privacy mode was previously enabled
- **AND** the app is cold-started
- **THEN** Settings shows Privacy mode on
- **AND** Home applies masking without requiring the user to toggle again

#### Scenario: Home peek does not update Settings

- **WHEN** Privacy mode is on
- **AND** the user temporarily reveals amounts on Home
- **THEN** the Settings Privacy mode switch remains on
- **AND** the persisted preference remains enabled

### Requirement: Mask four Home dashboard amounts

When Privacy mode is enabled and amounts are not temporarily revealed, the system SHALL display exactly these four Home values as `{currencySymbol} •••••` (active regional currency symbol): Total family budget, Monthly spending (spent amount), Monthly savings, and Monthly remaining (or monthly overspent amount in that same balance row). Other Home content MUST remain unmasked.

#### Scenario: Masked when privacy on and not revealed

- **WHEN** Privacy mode is on
- **AND** the user has not temporarily revealed amounts
- **THEN** Total family budget, spent this month, savings, and monthly remaining/overspent each show `{currencySymbol} •••••`
- **AND** indicative daily, progress percentage, subtitles, and upcoming bill amounts remain visible as normal formatted values

#### Scenario: Unmasked when privacy off

- **WHEN** Privacy mode is off
- **THEN** all four amounts show their normal formatted currency values
- **AND** no privacy eye control is shown beside Total family budget

### Requirement: Home-only temporary reveal with eye control

When Privacy mode is enabled, the system SHALL show an eye control beside Total family budget. Activating it SHALL temporarily reveal all four masked amounts on Home only. The temporary reveal MUST clear when the user leaves Home or when the app backgrounds, returning those amounts to the masked form while Privacy mode remains enabled.

#### Scenario: Eye visible only with privacy on

- **WHEN** Privacy mode is on
- **THEN** an eye control is visible beside Total family budget
- **WHEN** Privacy mode is off
- **THEN** the eye control is not visible

#### Scenario: Reveal all four amounts

- **WHEN** Privacy mode is on
- **AND** the user activates the eye control
- **THEN** Total family budget, spent this month, savings, and monthly remaining/overspent show their real formatted amounts

#### Scenario: Auto-hide when leaving Home

- **WHEN** amounts are temporarily revealed
- **AND** the user leaves the Home screen (including switching away from the Home tab)
- **THEN** the four amounts are masked again
- **AND** Privacy mode remains enabled

#### Scenario: Auto-hide when app backgrounds

- **WHEN** amounts are temporarily revealed
- **AND** the app moves to the background
- **THEN** the four amounts are masked again when the user returns (unless Privacy mode was turned off)
- **AND** Privacy mode remains enabled
