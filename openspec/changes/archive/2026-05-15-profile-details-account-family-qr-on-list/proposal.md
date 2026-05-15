## Why

Profile details was overloaded with a **family-invite QR** that duplicated concerns now covered by the **family list** flow (per-household QR, scan-to-join). Users need a clear separation: **account / identity** on profile details, **household invite and scan** only from the family listing experience. Specs still described the old combined surface; they must match the product split.

## What Changes

- **Profile details** becomes an **identity and account** screen: display name (edit), prominent **avatar** (deterministic from stable user id), the **cloud sync** account card (moved from the Settings root scroll), **sign out**, and a **destructive delete / reset** path with confirmation—**no** QR, **no** scan, **no** family-invite copy.
- **Compact Settings** SHALL **no longer** show the standalone **cloud sync** section on the main Settings screen; that surface moves **into profile details** only.
- **Family list** remains the **only** primary entry for **scan-to-join** and **show household QR** (already implemented in app; specs codify that boundary).
- **Household add-member scan** continues to use the same **invite payload contract** as documented for RPC flows; the spec SHALL **no longer** reference “profile details” as the source of that QR.
- **BREAKING** (spec-level): Requirements that mandated a family-invite QR on the profile details screen are **removed**; consumers of that spec must update tests and UI accordingly.

## Capabilities

### New Capabilities

_(None—all behavior is expressed as updates to existing capabilities.)_

### Modified Capabilities

- `profile-details-family-invite`: Retarget from “QR on profile details” to **profile identity and account actions** (avatar, **cloud sync card**, sign out, delete); remove QR and family-invite-on-profile requirements.
- `settings-compact-screen`: Compact Settings SHALL omit the standalone cloud sync block; profile summary → profile details remains; layout/scenarios updated so cloud sync is not expected on the Settings tab body.
- `household-family-details`: Update add-member QR contract wording so it does **not** depend on profile details; align with invite payload used in scan/join flows.
- `household-flow-features`: Add explicit requirement that **household QR and scan-to-join** primary affordances live on the **family list** feature, not on profile details.

## Impact

- Flutter: `lib/features/settings/view/profile_details_screen.dart` (remove QR, add avatar + cloud sync + actions), `lib/features/settings/view/settings_screen.dart` (remove `CloudSyncSettingsSection`), shared `cloud_sync_settings_section.dart` (reuse from profile details), strings/tokens, tests (`profile_details_screen_test.dart` etc.).
- Navigation: no new routes required if actions are inline; reuse existing logout/sync-before-logout path from auth.
- OpenSpec: `openspec/specs/profile-details-family-invite/spec.md` and related specs updated when the change is archived/applied per project workflow.
