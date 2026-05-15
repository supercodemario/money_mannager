## ADDED Requirements

### Requirement: Household-related primary surfaces live in dedicated feature packages

The system SHALL implement each household/family **primary surface** (family list, family members, create family invite, join family confirm, household scan, household QR share dialog) as its own feature directory under `lib/features/<name>/` using the same mandatory subfolders as other features (`bloc/`, `data/`, `models/` or an explicit placeholder, `view/`, `routes/`, `widgets/` as applicable). Each feature’s **view** layer SHALL depend on that feature’s **bloc** and **data** layers, not on another feature’s `view` imports for navigation targets.

#### Scenario: Settings opens family list feature only

- **WHEN** the user opens the Family entry from Settings as implemented
- **THEN** the app SHALL navigate using the `family_list` feature entrypoint (not a monolithic `household` umbrella screen that imports all other household views)

### Requirement: Cross-household navigation uses a composition-root contract

The system SHALL NOT import sibling household feature packages from one another solely to obtain `Navigator` targets. Navigation between those features SHALL go through a single **`HouseholdFlowNavigation`** abstraction provided to the widget tree (e.g. via an `InheritedWidget` at the app root). The concrete implementation MAY live under `lib/app/` and MAY construct `MaterialPageRoute` targets for each feature screen.

#### Scenario: Family list can open create family without importing create_family feature

- **WHEN** the family list feature needs to open create-family UI
- **THEN** it SHALL invoke the navigation contract (e.g. push create family) without a direct `import` of the `create_family` feature’s library for routing construction in the `family_list` feature package

### Requirement: Behavioral parity for existing household flows

The modularization SHALL preserve end-user-visible behavior for: signed-in gating for family list and actions, listing households and members, creating a family invite with QR, scanning to join (including invite preview and confirm), joining by household id where applicable, owner-only add-member scan, duplicate-member feedback, and sharing an existing household id via QR dialog. Regression in these flows SHALL be treated as a defect against `household-family-details` and this capability.

#### Scenario: Signed-out user still sees sign-in guidance on family list

- **WHEN** the user is not in a state that allows cloud household reads
- **THEN** the family list experience SHALL present the same class of sign-in or blocking guidance as before modularization (not a silent empty list without explanation)
