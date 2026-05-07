## ADDED Requirements

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
