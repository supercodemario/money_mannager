## Why

`PreferencesDetailsScreen` holds load/save logic, cloud household resolution, and UI in a single `StatefulWidget`, bypassing the project’s mandatory **view → bloc → data** flow. Other settings-adjacent flows (e.g. profile details) already use a cubit and feature-local repository. Refactoring preferences details aligns the settings feature with architecture rules, improves testability, and keeps persistence policy in one place without changing user-visible behavior.

## What Changes

- Add `bloc/`, `data/`, and `models/` under `lib/features/settings/` for preferences details only.
- Introduce `PreferencesDetailsCubit`, `PreferencesDetailsRepository`, and `PreferencesDetailsState` (mirror `profile_details` patterns).
- Thin `preferences_details_screen.dart` to `BlocProvider` + `BlocBuilder` and navigation only.
- Move private `_PreferenceDropdown` to `lib/features/settings/widgets/`.
- Wrap existing `UserPreferencesRepository`, profile id, household fetch, and default-household metadata in the feature repository (no new Drift tables).
- Add cubit/repository unit tests for load, regional upsert, and default household resolution.
- **No** change to regional propagation (`RegionalMaterialAppRoot`), preference option sets, or category management behavior.

## Capabilities

### New Capabilities

_None — behavior stays the same; structure and testability improve._

### Modified Capabilities

- `settings-compact-screen`: Document that preferences details MUST follow layered feature structure (view → bloc → data) and private widgets under `widgets/`.

## Impact

- **Code**: `lib/features/settings/view/preferences_details_screen.dart`; new files under `settings/bloc`, `settings/data`, `settings/models`, `settings/widgets`.
- **Data**: Reuses `UserPreferencesRepository`, `UserProfileRepository`, `HouseholdRemoteGateway` / `CloudSyncController`, `SyncMetadataStore` via repository composition.
- **Specs**: Delta under `settings-compact-screen` for architecture requirement.
- **Risk**: Low — refactor with existing manual QA paths (Preferences card → regional dropdowns → default household → manage categories).
