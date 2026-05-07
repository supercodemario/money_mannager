## 1. Settings Content and Tokens

- [x] 1.1 Add compact-settings labels to `AppStrings` for card titles, subtitles, badges, and toggle row text.
- [x] 1.2 Confirm token-based colors, spacing, and radii used by the redesigned settings UI (no raw feature-level constants).

## 2. Settings Screen Layout

- [x] 2.1 Refactor `SettingsScreen` into a scrollable compact layout containing profile section, 2x2 summary card grid, and quick-toggle rows.
- [x] 2.2 Implement four summary cards (Recurring, Family, Limits, Preferences) with Material `Icons.*` icon usage and matching visual hierarchy.
- [x] 2.3 Ensure the "Add Recurring Cost" CTA is removed from this screen implementation.

## 3. Interactions and Validation

- [x] 3.1 Preserve display-name edit interaction and profile update behavior from the existing screen.
- [x] 3.2 Add local state handling for Biometric Lock and Push Notifications toggle controls.
- [x] 3.3 Verify the updated settings screen renders without layout overflow across common mobile viewport sizes.
