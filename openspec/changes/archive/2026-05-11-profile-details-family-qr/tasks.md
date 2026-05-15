## 1. Dependencies and copy

- [x] 1.1 Add `qr_flutter` (or equivalent chosen in design) to `pubspec.yaml` and run `flutter pub get`.
- [x] 1.2 Add user-facing strings in `app_strings.dart`: profile details title, family-invite QR helper copy, and any accessibility labels per token rules.

## 2. Profile details screen

- [x] 2.1 Create `ProfileDetailsScreen` (or aligned name) under `lib/features/settings/view/`: load current profile via `AppServices.of(context).profiles.getCurrentProfile()` (or existing repository wiring used by Settings).
- [x] 2.2 Display **display name** prominently; handle loading/error states consistently with nearby settings screens.
- [x] 2.3 Render a QR (`QrImageView` / package API) encoding **`profile.id`** as UTF-8 string per design v1 contract.
- [x] 2.4 Show helper text that the QR is for **scan to add to family** (spec wording).

## 3. Settings entry point

- [x] 3.1 From `SettingsScreen`, make the profile summary section open Profile details via `Navigator.push` (same pattern as Preferences/Limits). Display-name **Edit** lives on **Profile details** (AppBar), not on Settings.
- [x] 3.2 Settings profile row is navigation-only (chevron); **Edit** on Profile details opens the rename dialog without conflicting with opening Profile details from Settings.

## 4. Verification

- [x] 4.1 Confirm QR payload: widget test asserts `QrImageView.data` equals `profile.id`; optional manual scan with a generic reader on device.
- [x] 4.2 Run analyzer/tests; fix any import or layout regressions.
