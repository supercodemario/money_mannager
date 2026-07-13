## ADDED Requirements

### Requirement: Single page-navigation system via auto_route
The application MUST use `auto_route` as the only mechanism for full-screen page navigation. Imperative page pushes via `Navigator.push` with `MaterialPageRoute` (or equivalent page routes) MUST NOT be used for app screens after this change.

#### Scenario: Opening a full-screen screen
- **WHEN** the user navigates to any full-screen app screen (for example Quick Add, settings detail, auth, or family flow)
- **THEN** navigation MUST go through the root `AppRouter` / auto_route APIs (typed routes or composition-root facades that call those APIs)

#### Scenario: No dual page-navigation styles
- **WHEN** the codebase is searched for page-level navigation
- **THEN** there MUST be no remaining `MaterialPageRoute` usages that present app screens

### Requirement: Root router replaces MaterialApp home
The app MUST start with `MaterialApp.router` configured with the root `AppRouter`. The previous `home:`-only entry MUST NOT be the production navigation entry point.

#### Scenario: Cold start
- **WHEN** the app launches
- **THEN** the initial route MUST present the existing app shell (bottom navigation host)

### Requirement: Feature route modules and bootstrap exports
Each feature that owns route-level screens MUST define routes under that feature’s `routes/` directory and register them through the project’s route registry pattern. Every `@RoutePage` screen MUST be exported from `lib/bootstrap_exports.dart` so codegen remains stable.

#### Scenario: Adding or migrating a screen
- **WHEN** a screen is registered for navigation
- **THEN** it MUST be annotated for auto_route, listed in bootstrap exports, and reachable via a typed route from the aggregated `AppRouter`

### Requirement: Cross-feature navigation stays at composition root
Features MUST NOT import other features’ screens or route types to navigate. Cross-feature flows MUST continue to use composition-root navigation facades (for example household and profile-details navigation), and those facades MUST implement navigation with auto_route only.

#### Scenario: Family join flow
- **WHEN** a feature starts create-family, household scan, join confirm, or family members navigation
- **THEN** it MUST call the household flow navigation facade (or equivalent composition-root API), not import the destination feature directly

### Requirement: Typed navigation results preserved
Flows that today return values through `Navigator.pop` MUST preserve equivalent typed results through auto_route (including nullable results).

#### Scenario: Household scan returns an id
- **WHEN** the user completes household scan successfully
- **THEN** the caller MUST receive the scanned identifier (or null on cancel) via the route result

#### Scenario: Join confirm returns a boolean
- **WHEN** the user finishes the join-family confirm screen
- **THEN** the caller MUST receive a boolean success/cancel result via the route result

### Requirement: Modals remain Flutter overlays
Dialogs and modal bottom sheets MUST continue to use Flutter overlay APIs (`showDialog`, `showModalBottomSheet`) and are NOT required to be auto_route pages.

#### Scenario: Confirmation dialog
- **WHEN** the UI shows a confirmation dialog or modal sheet
- **THEN** it MAY use `Navigator` pop within that overlay without treating the overlay as an app page route

### Requirement: Bottom shell behavior unchanged
Bottom navigation MUST continue to switch among shell tabs without requiring AutoTabsRouter in this change. The Add action MUST still open Quick Add as a pushed full-screen route via auto_route.

#### Scenario: Tab switch
- **WHEN** the user selects Home, Expenses, Insights, or Settings
- **THEN** the shell MUST show that tab’s content without a full-screen route push

#### Scenario: Add action
- **WHEN** the user selects Add in the bottom navigation (or an equivalent Quick Add entry point)
- **THEN** Quick Add MUST open as an auto_route full-screen page on top of the shell
