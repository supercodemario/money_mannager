## 1. Feature structure and models

- [x] 1.1 Add `lib/features/settings/models/preferences_details_state/preferences_details_state.dart` with phase enum, regional fields, households, and `defaultHouseholdId`
- [x] 1.2 Add `routes/.gitkeep` under `lib/features/settings/` if missing (align feature folder layout)

## 2. Data layer

- [x] 2.1 Add `PreferencesDetailsRepository` under `lib/features/settings/data/` wrapping profile id, `UserPreferencesRepository`, household fetch, `CloudSyncController` / `SyncMetadataStore` for default household
- [x] 2.2 Port existing `_load()` household bootstrap and default-selection policy into repository `loadSnapshot()` unchanged in behavior

## 3. Bloc layer

- [x] 3.1 Add `PreferencesDetailsCubit` with `load()`, `setCurrency`, `setLanguage`, `setNumberFormat`, and `setDefaultHousehold`
- [x] 3.2 Emit `loading` / `ready` / `error` phases; call repository upsert on each regional change (same immediate-save behavior as today)

## 4. View and widgets

- [x] 4.1 Move `_PreferenceDropdown` to `lib/features/settings/widgets/preference_dropdown.dart`
- [x] 4.2 Refactor `preferences_details_screen.dart` to `BlocProvider` + `BlocBuilder`; remove direct `AppServices` / `SyncMetadataStore` usage from widget state
- [x] 4.3 Preserve sections (Regional, Expense scope, Categories), empty household copy, and navigation to `CategoryManagementScreen`

## 5. Tests and verification

- [x] 5.1 Add unit tests for repository load (defaults when no prefs row; category filter not applicable — regional defaults and household list when sync allowed)
- [x] 5.2 Add cubit or repository test for default household resolution when metadata missing but households exist
- [x] 5.3 Run `flutter test` and `flutter analyze` on `lib/features/settings/`
- [x] 5.4 Manual QA: Settings → Preferences → change currency/language/format → confirm app-wide formatting updates; set default household when signed in; open Manage categories
