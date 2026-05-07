## ADDED Requirements

### Requirement: First-run Get Started before main tab content

The system MUST present a dedicated Get Started onboarding experience on launches where onboarding has not been completed. The **application shell** (including the bottom navigation bar) MAY remain mounted for visual continuity; primary **tab content** (dashboard, expenses, etc.) MUST NOT replace Get Started until onboarding is completed.

#### Scenario: Onboarding shown when not completed

- **WHEN** the application starts and persisted onboarding completion is absent or false
- **THEN** the system SHALL display the Get Started content as the active shell body and SHALL NOT show the primary `IndexedStack` tab surfaces (dashboard and other tabs) until onboarding completes
- **AND** the system SHOULD keep the same bottom navigation bar chrome visible (interaction MAY be disabled until onboarding completes)

#### Scenario: Main shell after completion

- **WHEN** the user completes Get Started through an explicit completion action
- **THEN** the system SHALL show the main tab content inside the application shell on subsequent renders

### Requirement: Onboarding completion persistence

The system MUST persist onboarding completion independently of expense data and limits so the user is not shown the full Get Started flow on every cold start after they have finished it once.

#### Scenario: Completion remembered across restarts

- **WHEN** the user has completed Get Started and the app process restarts later
- **THEN** the system SHALL skip the Get Started body and SHALL open the main tab content inside the application shell directly

### Requirement: Onboarding is not the dashboard home

The Get Started experience MUST NOT be implemented as part of the dashboard home layout; it MUST remain a separate screen so dashboard behavior and navigation are not conflated with onboarding UI.

#### Scenario: No dashboard home chrome as prerequisite

- **WHEN** Get Started is visible
- **THEN** the dashboard home screen and its standard app bar MUST NOT be required host surfaces for onboarding content

### Requirement: Bottom navigation style unchanged by onboarding work

Implementing or maintaining Get Started onboarding MUST NOT change the visual style or selection behavior of the main shell bottom navigation bar (including but not limited to colors, gradients, icon treatment, and selected-state chrome for tabs). Navigation changes are out of scope for this capability unless explicitly handled in a separate change.

#### Scenario: Shell bottom nav matches pre-onboarding product intent

- **WHEN** the user completes Get Started and lands on the main application shell
- **THEN** the bottom navigation bar SHALL remain consistent with existing shell implementation **without** onboarding-driven style updates applied as part of this capability’s work

### Requirement: Completion actions

The Get Started screen MUST offer at least one primary action that completes onboarding and one secondary action that allows the user to explore the app without implying a different persistence outcome for completion (both mark onboarding as completed for subsequent launches).

#### Scenario: User can dismiss onboarding explicitly

- **WHEN** the user activates a completion or explore-first control on Get Started
- **THEN** the system SHALL persist onboarding completion and SHALL transition to the main application shell
