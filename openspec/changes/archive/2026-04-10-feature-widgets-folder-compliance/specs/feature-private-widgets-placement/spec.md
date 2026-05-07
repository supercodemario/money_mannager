## ADDED Requirements

### Requirement: Feature child widgets live under `widgets/` (strict, project-wide)

For each feature under `lib/features/<feature_name>/`, any Flutter `Widget` implementation that is **not** the primary screen widget(s) in `view/` **MUST** be placed under `lib/features/<feature_name>/widgets/`. Files under `view/` **MUST** be limited to screen entry widgets and composition (imports from `widgets/`, `bloc/`, etc.). The same rules apply to **every** feature for a single, predictable layout.

#### Scenario: Dashboard home uses extracted widgets

- **WHEN** the dashboard home screen is implemented
- **THEN** substantial UI sections (e.g. hero, cards) **MUST NOT** be defined as separate widget classes in the same file as `DashboardHomeScreen`; they **MUST** reside under `lib/features/dashboard/widgets/`

#### Scenario: Expenses screen uses extracted widgets

- **WHEN** the expenses tab screen is implemented
- **THEN** substantial UI sections (e.g. daily list, monthly breakdown rows) **MUST NOT** be defined as separate widget classes in the same file as `ExpensesScreen`; they **MUST** reside under `lib/features/expenses/widgets/`

### Requirement: Cross-feature widgets stay in `share`

Widgets reused by more than one feature **MUST** live under `lib/share/widgets/`, not under a single feature’s `widgets/` folder.

#### Scenario: Shared component placement

- **WHEN** a widget is needed by both `dashboard` and `expenses`
- **THEN** it **MUST** be implemented under `lib/share/widgets/` (or moved there) rather than duplicated under feature `widgets/` folders
