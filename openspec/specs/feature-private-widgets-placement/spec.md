# feature-private-widgets-placement Specification

## Purpose

Keep feature folders predictable (`view/` vs `widgets/`) and ensure **any Flutter widget reused across features** lives under **`lib/share/widgets/`** so shared UI has a single home and features do not depend on each other for generic components.

## Requirements

### Requirement: Feature child widgets live under `widgets/` (strict, project-wide)

For each feature under `lib/features/<feature_name>/`, any Flutter `Widget` implementation that is **not** the primary screen widget(s) in `view/` **MUST** be placed under `lib/features/<feature_name>/widgets/`. Files under `view/` **MUST** be limited to screen entry widgets and composition (imports from `widgets/`, `bloc/`, etc.). The same rules apply to **every** feature for a single, predictable layout.

#### Scenario: Dashboard home uses extracted widgets

- **WHEN** the dashboard home screen is implemented
- **THEN** substantial UI sections (e.g. hero, cards) **MUST NOT** be defined as separate widget classes in the same file as `DashboardHomeScreen`; they **MUST** reside under `lib/features/dashboard/widgets/`

#### Scenario: Expenses screen uses extracted widgets

- **WHEN** the expenses tab screen is implemented
- **THEN** substantial UI sections (e.g. daily list, monthly breakdown rows) **MUST NOT** be defined as separate widget classes in the same file as `ExpensesScreen`; they **MUST** reside under `lib/features/expenses/widgets/`

### Requirement: Cross-feature widgets stay in `share/widgets` (strict)

Widgets that are **used by more than one feature** **MUST** be implemented under **`lib/share/widgets/`** (and exported via `lib/share/widgets/widgets.dart` as appropriate). They **MUST NOT** remain under `lib/features/<any_feature>/widgets/` once a second feature consumes them. When a widget is promoted from a single feature to shared use, it **MUST** be **moved** (not copied) to `lib/share/widgets/` and imports updated.

#### Scenario: Shared component placement

- **WHEN** a widget is needed by both `dashboard` and `expenses`
- **THEN** it **MUST** be implemented under `lib/share/widgets/` (or moved there) rather than duplicated under feature `widgets/` folders

#### Scenario: Promotion after second consumer

- **WHEN** a widget already exists under one feature’s `widgets/` and a second feature needs the same UI
- **THEN** the widget **MUST** be relocated to `lib/share/widgets/` and the original feature **MUST** import it from there
