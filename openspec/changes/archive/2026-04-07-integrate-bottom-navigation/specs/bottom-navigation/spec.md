## ADDED Requirements

### Requirement: App provides bottom navigation for primary sections
The system MUST provide a bottom navigation shell that exposes the primary app sections as tabs:
- Home (Dashboard)
- Expenses
- Add (central action)
- Insights
- Settings

#### Scenario: User switches tabs
- **WHEN** the user taps a bottom navigation item
- **THEN** the shell SHALL switch the visible tab content to the selected section

### Requirement: Bottom navigation follows token-first styling
The bottom navigation UI MUST be implemented using shared tokens (colors/spacing/radius) and MUST NOT use raw hex colors or hardcoded pixel constants in feature view code.

#### Scenario: Bottom navigation uses tokens
- **WHEN** the bottom navigation bar is rendered
- **THEN** its background, radius, spacing, and text/icon colors SHALL come from shared tokens under `lib/share/tokens/`

### Requirement: Bottom navigation uses glass/blur visual treatment
The bottom navigation UI MUST implement a “glass” look consistent with the Stitch design:
- translucent surface background
- backdrop blur
- soft ambient shadow

#### Scenario: Bottom navigation renders glass surface
- **WHEN** the bottom navigation is displayed over content
- **THEN** the bar SHALL render a translucent surface with blur and a soft ambient shadow

### Requirement: Labels are centralized
Tab labels MUST be sourced from centralized string tokens.

#### Scenario: Tab labels use AppStrings
- **WHEN** a tab label is shown
- **THEN** it SHALL use constants from `lib/share/tokens/app_strings.dart`

