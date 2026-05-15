## Why

Family onboarding needs a low-friction way for one member to share their identity so another device can **scan and add them** to a household. Today the Settings profile area only shows display name and inline edit; there is no dedicated surface for **profile id** or a **scannable QR**, which blocks the “scan to add into family” flow.

## What Changes

- Add a **Profile details** screen reachable from the compact Settings **profile** section, showing **display name** and a **QR code** encoding the user’s **local profile id** for use by the family-add scanner (see design for v1 payload format).
- Keep existing **Edit** display-name behavior available from Settings (and optionally mirrored on the new screen per design).
- Add a **Flutter dependency** for QR rendering (e.g. `qr_flutter`), unless an existing in-tree solution is chosen in implementation.
- Add strings/tokens for profile details title and family-invite helper copy.

## Capabilities

### New Capabilities

- `profile-details-family-invite`: Profile details screen with display name and QR representing the profile identifier for family invite scanning.

### Modified Capabilities

- `settings-compact-screen`: Profile summary on Settings SHALL expose navigation to the new profile details screen while preserving existing display-name editing.

## Impact

- **UI:** `lib/features/settings/view/settings_screen.dart` (or equivalent) — entry from profile card/row; new screen under `lib/features/settings/view/` (or `profile/` if split later).
- **Data:** `UserProfileRepository.getCurrentProfile()` / `id` — no schema change for v1.
- **Dependencies:** New package for QR generation widget (typical: `qr_flutter`); `pubspec.yaml`.
- **Strings:** `lib/share/tokens/app_strings.dart` (and related tokens per project rules).
- **Family scanner side:** Out of scope for this change except specifying QR payload contract in design; actual “add member” backend/UI can follow.
