# settings-compact-screen Specification

## Purpose

Settings tab presents a compact, dashboard-like layout with summary cards and key toggles, aligned with the Stitch compact settings reference, while preserving profile editing.

## Requirements

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

### Requirement: Recurring summary card opens recurring templates management

The system SHALL navigate to a **recurring templates management** screen when the user activates the **Recurring** summary card on the compact Settings overview.

#### Scenario: Tap Recurring card opens management

- **WHEN** the user taps the Recurring summary card on the Settings tab
- **THEN** the app SHALL present the recurring templates management screen

### Requirement: Recurring templates management screen lists all templates with scheduling toggle

The recurring templates management screen SHALL list **every** persisted recurring template (enabled and disabled). Each row (or equivalent list item) SHALL expose the template’s identifying information (at least title and due presentation consistent with the app) and a **switch** (or equivalent binary control) bound to that template’s **scheduling enabled** state. Toggling the control SHALL persist immediately or on clear commit consistent with app patterns and SHALL reflect the exclusion rules defined in the recurring-payments capability.

#### Scenario: Disabled templates visible only here

- **WHEN** a template has scheduling disabled
- **THEN** it SHALL still appear in this management list with the switch in the off position

#### Scenario: Switch turns scheduling off

- **WHEN** the user moves the scheduling switch to off for a template
- **THEN** the system SHALL persist scheduling disabled and the template SHALL stop appearing on the home dashboard and Expenses Recurring list per recurring-payments rules

### Requirement: Recurring templates management screen provides edit and delete

The recurring templates management screen SHALL provide **edit** and **delete** actions for each template. **Edit** SHALL open the same add/edit recurring flow used elsewhere, with fields pre-filled from the selected template. **Delete** SHALL remove the template using the same persistence rules as the existing delete-recurring behavior (including not silently removing historical paid expenses inappropriately).

#### Scenario: Edit opens flow with template context

- **WHEN** the user chooses edit for a template
- **THEN** the app SHALL open the recurring add/edit UI populated with that template’s saved values

#### Scenario: Delete uses existing semantics

- **WHEN** the user confirms delete for a template (if confirmation is required)
- **THEN** the system SHALL apply the same deletion behavior as the established recurring template delete path

### Requirement: Recurring templates management screen provides FAB for add

The recurring templates management screen SHALL show a **floating action button** (or equivalent primary add affordance) that navigates to the **existing** add recurring payment screen for creating a **new** template.

#### Scenario: FAB opens add recurring

- **WHEN** the user activates the add affordance on the management screen
- **THEN** the app SHALL present the existing add recurring payment flow for a new template

### Requirement: Limits summary card opens expense limits detail

The system SHALL navigate to the **expense limits** detail screen when the user activates the **Limits** summary card on the compact Settings overview.

#### Scenario: Tap Limits card opens expense limits

- **WHEN** the user taps the Limits summary card on the Settings tab
- **THEN** the app SHALL present the expense limits detail screen

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
