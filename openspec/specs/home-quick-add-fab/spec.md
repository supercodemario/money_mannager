# home-quick-add-fab Specification

## Purpose
TBD - created by archiving change home-quick-add-fab. Update Purpose after archive.
## Requirements
### Requirement: Home dashboard exposes a quick-add floating action
The system MUST show a floating action control on the home (dashboard) screen that allows the user to start adding an expense.

#### Scenario: User sees quick add on home
- **WHEN** the home dashboard screen is displayed
- **THEN** a floating action affordance for adding an expense SHALL be visible

### Requirement: Quick-add uses the same entry path as the Add tab
The system MUST provide the same add-expense experience when the user starts the flow from the home floating action as when the user selects the central Add tab in the bottom navigation.

#### Scenario: User opens add expense from home FAB
- **WHEN** the user activates the home floating action for quick add
- **THEN** the app SHALL present the add-expense experience consistent with the bottom navigation Add tab

### Requirement: Token-first styling for the home quick-add control
The home floating action MUST use shared design tokens for colors, spacing, and shape (no ad-hoc hex colors or raw pixel constants in feature UI code for this control).

#### Scenario: Home FAB uses tokens
- **WHEN** the home floating action is rendered
- **THEN** its styling SHALL derive from shared tokens under `lib/share/tokens/`

