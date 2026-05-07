## Why

The app currently uses the default Flutter demo theme and has no shared, token-based styling, which makes it easy for feature UI to drift and violate the project’s strict “token-first / no raw hex or px” rule. Establishing a base theme now creates a consistent visual foundation aligned with the Stitch design system (“Financial Sanctuary”) before feature development accelerates.

## What Changes

- Introduce a **token-first** design system foundation under `lib/share/` (colors, typography, spacing, radius) derived from the Stitch design system.
- Add a centralized app theme (`ThemeData`) that consumes these tokens and becomes the default theme used by the app entrypoint.
- Provide a small set of shared UI primitives (e.g., card/surfaces, buttons, inputs) that encode the design rules (no dividers, minimal borders, tonal layering, controlled elevation).
- Establish conventions that keep feature UI in compliance: feature `view/` code references tokens/components instead of using raw hex colors, raw spacing, or ad-hoc component styling.

## Capabilities

### New Capabilities

- `base-theme`: Define and apply a token-driven base theme (colors/typography/shape/spacing) aligned to the Stitch design system, and provide shared primitives so features can build UI without violating token-first rules.

### Modified Capabilities

- `project-structure`: Clarify/enforce the existing structure rules by explicitly defining how tokens/theme/primitives live under `lib/share/` and how feature views must consume them.

## Impact

- **Code structure**: Adds/uses `lib/share/tokens/`, `lib/share/theme/`, and `lib/share/widgets/` as the foundation for all feature UI.
- **Dependencies**: May introduce UI/theming-related dependencies (fonts, optional helpers) and requires wiring in `main.dart`.
- **Development workflow**: Feature development becomes dependent on tokens/primitives; direct styling inside features becomes constrained by the token-first rule.

