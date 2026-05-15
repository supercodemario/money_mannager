## Context

The app already enforces a **feature-first** layout in documentation (`PROJECT_STRUCTURE_SPEC`) and uses **Supabase-backed** household RPCs and RLS (`HouseholdRemoteGateway`). Family UX (list, members, create invite, join confirm, scan, share household QR) previously lived under one `household` feature with direct imports between screens, which made boundaries unclear and encouraged cross-feature imports from Settings.

## Goals / Non-Goals

**Goals:**

- One **feature package per primary screen** (or dialog surface) for household flows, each with **bloc**, **data** (repository wrapping the remote gateway), **models** where needed, **view**, **routes** (stub or future `auto_route`), and **widgets** for non-screen building blocks.
- **No imports** from one household-related feature to another for navigation; use a **small core navigation interface** implemented at app composition time.
- Preserve **user-visible behavior** (sign-in gating, owner-only add, join/invite flows, QR contracts) as defined in existing specs.
- Register **`HouseholdFlowScope`** at the app root so any subtree can resolve the navigation implementation.

**Non-Goals:**

- Replacing imperative `Navigator` pushes with `auto_route` route tables in this change (may follow later).
- Moving `HouseholdRemoteGateway` out of `lib/data/remote/` or changing RPC contracts.
- Changing copy, visual design, or Supabase policies beyond what is required for wiring.

## Decisions

1. **Navigation interface in `lib/core/navigation/`**  
   **Decision:** Define `HouseholdFlowNavigation` abstract class (methods return `Future` where appropriate) with DTO types referenced from `HouseholdRemoteGateway` only where unavoidable (e.g. `FamilyInvitePreview`).  
   **Rationale:** Keeps feature modules free of sibling feature imports; core may depend on shared data types.  
   **Alternative considered:** Put the interface under `lib/app/` only — rejected because “navigation contract” is cross-cutting and `app` already holds the concrete implementation.

2. **Concrete implementation + DI via `InheritedWidget`**  
   **Decision:** `AppHouseholdFlowNavigation` implements the interface and is exposed through `HouseholdFlowScope` wrapping the tree inside `AppServices` in `MyApp`.  
   **Rationale:** Matches Flutter patterns; tests can wrap with the same scope when pushing family routes.

3. **State management: `flutter_bloc` Cubits**  
   **Decision:** Use `Cubit` + repository per feature for list/members/create/join flows; scanner keeps a minimal cubit if the screen is otherwise UI-heavy.  
   **Rationale:** Aligns with project rule naming `bloc/`; lighter than full event/state `Bloc` for CRUD-style loads.

4. **Household scan paste sheet**  
   **Decision:** Move paste UI to `household_scan/widgets/` as a public widget per widget-placement rules.  
   **Rationale:** Satisfies “screens only in view/” guidance.

## Risks / Trade-offs

| Risk | Mitigation |
|------|------------|
| Forgetting `HouseholdFlowScope` in a test harness | Document in change tasks; use `MyApp` in tests where possible |
| Interface drift when adding a new household screen | Extend `HouseholdFlowNavigation` in one place; compiler surfaces missing methods |
| Duplication of gateway calls vs old monolith | Repositories stay thin wrappers over existing gateway methods |

## Migration Plan

1. Land new features + navigation scope behind the same runtime behavior.  
2. Switch Settings and any other entrypoints to the new `FamilyListScreen` path.  
3. Delete obsolete `lib/features/household` tree.  
4. Run `dart analyze` and targeted `flutter test`.

**Rollback:** Revert commits restoring the old folder and imports (no data migration).

## Open Questions

- Whether to later merge `HouseholdFlowNavigation` into a global `AppRouter` when `auto_route` is adopted project-wide.
