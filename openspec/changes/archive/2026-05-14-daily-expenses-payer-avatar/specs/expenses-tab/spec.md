## ADDED Requirements

### Requirement: Daily expense rows show the recording member with a deterministic generated avatar

In **Daily** mode, each expense row in the transaction list SHALL show which **local user profile** created the expense (the persisted `created_by_user_id`), using that profile’s **`display_name`** as the readable label and a **small generated avatar** whose visual is determined solely by the profile’s **`id`** (stable across display name changes). The avatar SHALL be produced with the **`avatar_plus`** package (or compatible Multiavatar-backed implementation) at list-appropriate dimensions. Layout and spacing SHALL use shared design tokens (no ad-hoc magic numbers for colors in feature views).

#### Scenario: Row shows creator name and avatar

- **WHEN** the user views Daily mode for a day that includes at least one expense
- **THEN** each listed expense row SHALL include the **display name** of the user profile referenced by that expense’s `created_by_user_id` and SHALL include the **generated avatar** for that profile’s `id`

#### Scenario: Avatar does not require a profile image column

- **WHEN** the user profile row has only `id` and `display_name` populated (no photo URL field)
- **THEN** the row SHALL still render the generated avatar from the profile `id` without requiring network image fetch for that member

#### Scenario: Monthly and Recurring modes unchanged

- **WHEN** the user selects Monthly or Recurring payments mode on the Expenses tab
- **THEN** the system SHALL NOT require the same per-row creator avatar treatment as introduced for Daily mode in this requirement (unless an existing shared row component is extended without changing those modes’ information architecture)
