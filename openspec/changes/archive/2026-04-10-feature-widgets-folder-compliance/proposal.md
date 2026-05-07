## Why

You asked for **feature-level child widgets** to live under `lib/features/<feature>/widgets/`, but `expenses_screen.dart` and `dashboard_home_screen.dart` still define large **private** widget classes next to the screen in `view/`. That hurts consistency, makes screens harder to scan, and makes the rule easy to miss for future work.

## What Changes

- Document **why** the codebase drifted (written spec says `widgets/` is *optional*; implementation prioritized speed).
- The **project structure rule** is now **strict** in `openspec/specs/PROJECT_STRUCTURE_SPEC.md`: non-screen UI building blocks **must** live under that feature’s `widgets/` directory (with narrow exceptions in §2.1), and the same layout applies **project-wide** for readability.
- **Refactor** `DashboardHomeScreen` and `ExpensesScreen` so their child widgets are moved into `lib/features/dashboard/widgets/` and `lib/features/expenses/widgets/` respectively; `view/` files keep screen composition only.
- Optionally add a short **lint / review checklist** note (no new tooling required in v1 unless tasks expand).

## Capabilities

### New Capabilities

- `feature-private-widgets-placement`: Normative rules for where feature-scoped (non-screen) widgets live relative to `view/`.

### Modified Capabilities

- *(none)* — `PROJECT_STRUCTURE_SPEC.md` will be updated in-repo as part of implementation tasks to match the clarified rule (same change, avoids awkward delta formatting for the legacy markdown spec).

## Impact

- **Files:** `lib/features/dashboard/view/dashboard_home_screen.dart`, `lib/features/expenses/view/expenses_screen.dart`, plus new files under `widgets/` in those features.
- **Behavior:** None intended (structure-only refactor).
- **DX:** Clearer place to find UI pieces; easier reviews.
