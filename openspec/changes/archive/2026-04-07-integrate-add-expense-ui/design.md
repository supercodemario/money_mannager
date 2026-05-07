## Context

The project already has:

- A token-driven base theme under `lib/share/` (colors, spacing, radius, typography)
- A bottom navigation shell under `lib/features/shell/view/app_shell.dart` with a central “Add” tab
- A Stitch-generated “Add Expense” screen reference (HTML + screenshot) that defines layout and styling

The Add Expense Stitch screen includes:

- A top app bar with back navigation and title (“New Expense”)
- A large amount entry area (currency symbol + centered numeric input)
- Two bento-style form fields (Date, Note)
- A category selection grid (icon-in-circle + label)
- Primary CTA (“Save Expense”) with gradient and large radius, plus secondary “Cancel”

## Goals / Non-Goals

**Goals:**

- Implement a new `add-expense` feature under `lib/features/add_expense/` with the Add Expense screen UI
- Keep all UI token-first (no raw hex / raw spacing literals in feature views) and string-tokenized via `AppStrings`
- Integrate the screen into the app shell: the central “Add” tab displays the Add Expense screen

**Non-Goals:**

- Persisting expenses to a database or syncing to a backend
- Full category management (editing categories, dynamic icons) beyond a starter in-memory list
- Form validation rules beyond basic UX defaults (can be extended later)

## Decisions

1. **Feature placement**

- **Decision**: Implement under `lib/features/add_expense/` with required subfolders (`bloc/`, `data/`, `models/`, `routes/`, `view/`).
- **Rationale**: Matches the strict feature-first structure and isolates UI.

1. **Screen composition**

- **Decision**: Build the screen with a single `AddExpenseScreen` and small private widgets for sections (amount header, fields, category grid, action buttons).
- **Rationale**: Keeps the initial implementation straightforward while preserving maintainability.

1. **Category grid data**

- **Decision**: Start with a simple in-memory list of categories (id, label, icon, token colors) within the feature `data/` (or `models/` + a small provider) until a category feature exists.
- **Rationale**: Allows UI completion without cross-feature imports.

1. **Navigation integration**

- **Decision**: Update the shell’s “Add” tab body from placeholder to `AddExpenseScreen`.
- **Rationale**: Matches the spec change for `bottom-navigation` and makes “Add” functional.

## Risks / Trade-offs

- **[Risk] Token-first enforcement inside feature** → **Mitigation**: rely on `AppStrings` + shared tokens and avoid inline literals.
- **[Risk] Amount input formatting** → **Mitigation**: start with a numeric `TextField` and add formatting in a follow-up change (e.g., masked currency input).
- **[Risk] Category visuals drift from Stitch** → **Mitigation**: centralize category icon container styles and keep sizing/radius consistent via tokens.