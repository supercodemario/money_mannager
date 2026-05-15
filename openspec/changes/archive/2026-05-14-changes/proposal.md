## Why

Household and family flows were implemented as multiple screens under a single `household` feature folder, which drifted from the project’s **feature-per-screen** layout (each feature owns `bloc/`, `data/`, `models/`, `view/`, `routes/`, `widgets/` where applicable) and from the **no cross-feature imports** rule. Modularizing these surfaces keeps navigation explicit, makes ownership clear, and matches how other domains are expected to evolve.

## What Changes

- Split household-related UI into dedicated features: `family_list`, `family_members`, `create_family`, `join_family_confirm`, `household_scan`, and `household_qr_share`, each with the standard folder skeleton and **bloc + repository** layers for orchestration and remote calls.
- Introduce a **composition-root navigation contract** (`HouseholdFlowNavigation` in `lib/core/navigation/`, implemented by `AppHouseholdFlowNavigation` and provided via `HouseholdFlowScope` in `lib/main.dart`) so feature packages do not import one another for `Navigator` pushes.
- Add **`flutter_bloc` / `bloc`** dependencies for the new cubits.
- Update **Settings** to open the family experience through the **`family_list`** feature entrypoint only.
- **Remove** the monolithic `lib/features/household` tree once superseded (no duplicate routes or screens).

## Capabilities

### New Capabilities

- `household-flow-features`: Requirements for the modular household/family feature set, composition-root navigation between those features, and parity constraints so existing user-visible flows (list, members, create invite, join confirm, scan, share QR) remain consistent with product expectations.

### Modified Capabilities

- `household-family-details`: Delta to tie the existing member/owner/QR scenarios to the new module boundaries and navigation contract without weakening signed-in gating, owner-only add behavior, or duplicate-member handling.

## Impact

- **Code:** `lib/features/family_list`, `family_members`, `create_family`, `join_family_confirm`, `household_scan`, `household_qr_share`; `lib/app/household_flow_scope.dart`, `lib/app/household_flow_navigation_impl.dart`; `lib/core/navigation/household_flow_navigation.dart`; `lib/main.dart`; `lib/features/settings/view/settings_screen.dart`; removal of `lib/features/household`.
- **Dependencies:** `pubspec.yaml` (`bloc`, `flutter_bloc`).
- **Tests:** Any widget tests that pump the app root must include `HouseholdFlowScope` (or use `MyApp`, which wraps it) when exercising family navigation.
