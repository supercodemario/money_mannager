## Context

The current `SettingsScreen` primarily exposes profile display-name editing and does not reflect the Stitch compact settings composition requested by product direction. The requested UI introduces multiple visual groups (summary cards + toggle rows) and removes the recurring CTA button, while still preserving existing profile edit behavior and app-wide token usage conventions.

This change is a UI integration across feature and shared token layers with no backend schema changes. The implementation should stay aligned with existing app patterns (Material `Icons.*`, `AppCard`, `AppColors`, `AppSpacing`, `AppRadius`, and `AppStrings`).

## Goals / Non-Goals

**Goals:**
- Deliver a compact settings layout with four summary cards and two toggles.
- Keep profile display-name editing available in the same screen.
- Exclude the "Add Recurring Cost" button from the screen.
- Ensure icon usage follows existing in-app icon patterns (Material Icons).

**Non-Goals:**
- Wire new navigation destinations for each card in this change.
- Persist biometric/push settings to storage or remote APIs.
- Redesign bottom navigation or shell architecture.

## Decisions

1. **Single-screen composition within existing `SettingsScreen`**
   - Keep all new UI in `lib/features/settings/view/settings_screen.dart` to avoid unnecessary routing complexity.
   - Alternative considered: splitting into multiple widgets/files now. Deferred because scope is a targeted visual integration and can be extracted later if needed.

2. **Token-first styling and shared widgets**
   - Reuse existing design tokens and `AppCard` for consistency and maintainability.
   - Alternative considered: ad-hoc style constants in feature code. Rejected to prevent drift from app theme.

3. **Material icons for all new elements**
   - Use `Icons.*` consistently because this app already relies on Material iconography.
   - Alternative considered: matching Stitch's symbol names literally. Rejected because the app does not use the web Material Symbols set directly.

4. **Local toggle state only**
   - Manage Biometric Lock and Push Notifications with local boolean state in this phase.
   - Alternative considered: persistence wiring now. Rejected due to missing confirmed settings storage contract and because UI parity is the immediate objective.

## Risks / Trade-offs

- **[Risk] Static summary values on cards may be interpreted as live data** → **Mitigation:** treat these values as UI placeholders and plan follow-up integration with actual recurring/family/limits sources.
- **[Risk] Increased settings screen complexity may reduce readability on small devices** → **Mitigation:** use scrollable layout, compact spacing tokens, and card aspect ratios that collapse cleanly.
- **[Risk] Future persistence for toggles may require refactor** → **Mitigation:** keep toggle widgets isolated so state source can be swapped from local state to repository/service later.

## Migration Plan

- No data migration is required.
- Release can be done as a standard app update.
- Rollback strategy: revert `SettingsScreen` and added settings string keys if visual regression is detected.
