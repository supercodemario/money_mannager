## 1. Specs and strings

- [x] 1.1 Confirm final **Delete** semantics (local reset vs cloud account delete) with product; adjust `design.md` Open Questions if needed before closing task 2.4.
- [x] 1.2 Add or update `AppStrings` (and any semantics labels) for profile details: avatar, sign out, delete, confirmation copy; remove or stop using profile-details QR-specific strings where obsolete.

## 2. Profile details UI

- [x] 2.1 Replace `QrImageView` / `qr_flutter` usage on `ProfileDetailsScreen` with `MemberAvatar` (or shared equivalent) using the **stable id** rule from `design.md`.
- [x] 2.2 Embed **`CloudSyncSettingsSection`** (or the extracted shared layout from `design.md`) on `ProfileDetailsScreen`; remove `CloudSyncSettingsSection` from `SettingsScreen`.
- [x] 2.3 Add **Sign out** control wiring to the **same** sync-before-logout + wipe flow as `auth_screen.dart` (extract shared helper or delegate—avoid duplicated logic).
- [x] 2.4 Add **Delete** (or product-approved label) with **confirmation** dialog; implement the chosen deletion path (per 1.1) without silent partial teardown.

## 3. Dependencies and cleanup

- [x] 3.1 Remove `qr_flutter` import from `profile_details_screen.dart` if no longer used; drop `pubspec.yaml` dependency only if unused elsewhere in the project.
- [x] 3.2 Add or adjust **Settings** / **profile details** widget tests so compact Settings does not expect the cloud sync card on the root scroll and profile details does.

## 4. Tests

- [x] 4.1 Update `test/profile_details_screen_test.dart` (and related tests) to assert **avatar**, **cloud sync section**, and **no QR**; add coverage for sign-out and delete affordances where practical (mocks/fakes as existing patterns allow).

## 5. OpenSpec workflow

- [x] 5.1 After implementation, archive/merge spec deltas into `openspec/specs/` per project OpenSpec apply/archive workflow so baseline specs match the change.
