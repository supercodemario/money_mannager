## Why

The app needs a consistent, token-first bottom navigation that matches the Stitch “Refined Dashboard” design language (glass/blur, soft ambient shadow, emphasized active tab, and a central “Add” action). Adding this now prevents each feature from inventing its own navigation patterns and ensures the home experience feels cohesive.

## What Changes

- Introduce a bottom navigation shell that hosts primary sections (Home/Dashboard, Expenses, Add, Insights, Settings).
- Implement a token-driven “glass” bottom nav bar (blur + translucent surface + soft shadow) aligned with the design system (“Financial Sanctuary”).
- Standardize labels and icon behaviors (active tile style, center “Add” prominence) while keeping feature code token-first and free of raw literals.

## Capabilities

### New Capabilities

- `bottom-navigation`: Provide a shared, token-driven bottom navigation shell and API for primary app sections (tabs), including a prominent central “Add” action.

### Modified Capabilities

- `project-structure`: Enforce/clarify that navigation UI is implemented as a feature shell and that tab labels come from `lib/share/tokens/app_strings.dart` (no hardcoded strings in feature views).

## Impact

- **UI entrypoint**: App root may move to (or wrap with) a shell widget hosting the bottom navigation.
- **Feature integration**: Features will plug into the shell as tab pages without cross-feature imports.
- **Shared tokens/widgets**: May add/extend shared navigation widget(s) under `lib/share/widgets/` to encode the “glass” rules.