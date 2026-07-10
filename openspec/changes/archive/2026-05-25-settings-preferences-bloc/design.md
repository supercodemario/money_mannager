## Context

`lib/features/settings/` currently contains only `view/` screens. `PreferencesDetailsScreen` is a `StatefulWidget` that calls `AppServices`, `SyncMetadataStore`, and household APIs directly. `ProfileDetailsScreen` in `lib/features/profile_details/` already demonstrates the target pattern: thin view, `BlocProvider`, `ProfileDetailsCubit`, and `ProfileDetailsRepository` wrapping shared `lib/data/` repositories.

Regional preferences behavior is specified in `regional-preferences` and implemented via `UserPreferencesRepository` plus `RegionalMaterialAppRoot` — this change does not alter that contract.

## Goals / Non-Goals

**Goals:**

- Enforce **view → bloc → data** for preferences details within the `settings` feature.
- Centralize load/save and default-household resolution in `PreferencesDetailsRepository` + `PreferencesDetailsCubit`.
- Keep all existing UI sections, option sets (`USD`/`EUR`/`INR`, `en`/`es`/`fr`, `us`/`eu`/`in`), and navigation to category management.
- Add focused unit tests on repository/cubit policy (defaults, household list when sync allowed, upsert on change).

**Non-Goals:**

- Refactoring `settings_screen.dart`, `expense_limits_screen.dart`, or other settings views.
- New preference fields, routes/`auto_route` registration, or API/schema changes.
- Moving preferences details to a separate top-level feature (would complicate navigation to `CategoryManagementScreen` under the same feature).
- Changing `RegionalMaterialAppRoot` or migrating all amount format call sites.

## Decisions

1. **Keep preferences under `lib/features/settings/`**  
   **Choice**: Add `bloc/`, `data/`, `models/`, `widgets/` siblings to existing `view/`, not a new `preferences_details` feature.  
   **Rationale**: Category management navigation stays intra-feature; matches `household-flow-features` guidance for primary surfaces without cross-feature `view` imports.  
   **Alternative**: Top-level `preferences_details` feature — rejected due to import boundary with `category_management_screen`.

2. **Cubit + repository, not ChangeNotifier**  
   **Choice**: `PreferencesDetailsCubit extends Cubit<PreferencesDetailsState>` like `ProfileDetailsCubit`.  
   **Rationale**: Project standard; consistent testing with `bloc_test` if added later.

3. **State shape**  
   **Choice**: `PreferencesDetailsPhase` (`loading`, `ready`, `error`), fields for `userId`, `currency`, `language`, `numberFormat`, `households`, `defaultHouseholdId`, optional `saving` flag.  
   **Rationale**: Mirrors profile details; supports loading UI already present.

4. **Repository composition**  
   **Choice**: `PreferencesDetailsRepository` accepts injected `UserPreferencesRepository`, `UserProfileRepository`, `CloudSyncController`, and household access (gateway or thin wrapper). Methods: `loadSnapshot()`, `upsertRegional(...)`, `setDefaultHousehold(id)`.  
   **Rationale**: Feature `data/` wraps `lib/data/` — no duplicate Drift tables. Household bootstrap (`ensurePersonalHousehold`, pick default when missing) moves from view into repository.

5. **View structure**  
   **Choice**: `PreferencesDetailsScreen` provides `BlocProvider` with dependencies from `AppServices.of(context)`; body is `BlocBuilder` rendering existing layout. `_PreferenceDropdown` → `settings/widgets/preference_dropdown.dart`.  
   **Rationale**: Satisfies `feature-private-widgets-placement` and keeps `view/` thin.

6. **Constants for dropdown options**  
   **Choice**: Keep static option lists on cubit or a small model file (`preferences_option_sets.dart`), not in the view.  
   **Rationale**: View stays declarative.

## Risks / Trade-offs

- **[Risk] Subtle behavior drift during move** (e.g. default household auto-pick) → **Mitigation**: Port `_load()` logic verbatim into repository; add tests comparing totals/ids for signed-in and signed-out paths.  
- **[Risk] `settings` feature still incomplete** (other screens lack bloc) → **Mitigation**: Document in tasks; only preferences scope in this change.  
- **[Risk] Error path unused today** → **Mitigation**: Emit `error` phase on load failure; show simple retry or message (match profile details minimal handling).

## Migration Plan

1. Add repository + state + cubit with tests.  
2. Refactor screen to bloc; extract dropdown widget.  
3. Run `flutter test` and manual Preferences QA (regional saves, default household, category entry).  
4. No DB migration or feature flags.

## Open Questions

- Whether to show a SnackBar on save failure (currently silent) — recommend minimal log + optional SnackBar in cubit if time permits; not required for parity.
