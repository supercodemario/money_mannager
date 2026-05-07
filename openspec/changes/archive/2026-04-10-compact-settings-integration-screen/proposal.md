## Why

The current settings screen only supports editing display name, which does not match the compact settings experience requested from the Stitch reference. A richer settings surface is needed now so users can access recurring, family, limits, preferences, and core toggles from one screen without extra navigation.

## What Changes

- Replace the minimal settings page with a compact, card-based settings layout aligned to the Stitch "Compact Settings" screen.
- Include four top cards (Recurring, Family, Limits, Preferences) with icon-first presentation using in-app Material icons and token-based styling.
- Add two settings toggle rows for Biometric Lock and Push Notifications with clear enabled/disabled states.
- Remove the "Add Recurring Cost" call-to-action from this implementation scope.
- Preserve existing profile edit functionality within the redesigned settings page.

## Capabilities

### New Capabilities

- `settings-compact-screen`: Settings tab presents a compact, dashboard-like layout with summary cards and key toggles, while keeping profile editing available.

### Modified Capabilities

- _(none)_ — Existing bottom navigation and profile persistence contracts remain unchanged; this is a new settings UI capability.

## Impact

- `lib/features/settings/view/settings_screen.dart` for the redesigned layout and interaction states.
- `lib/share/tokens/app_strings.dart` for new user-facing settings labels.
- Reference assets under `stitch-reference/family-expense-tracker-12107255462624662036/compact-settings/` (screenshot + HTML) for visual alignment.
