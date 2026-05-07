## Context

The repository is currently a default Flutter scaffold (`lib/main.dart`) with no token-first theming foundation. The project has strict architectural rules requiring:

- Feature-first structure under `lib/features/`
- Shared design tokens and reusable UI under `lib/share/`
- “Token first” UI: feature views must not use raw hex colors or raw pixel constants

Separately, the Stitch design system (“Financial Sanctuary”) defines the desired UI language:

- Tonal surface hierarchy (`surface`, `surface-container-*`) instead of borders/dividers (“No-Line Rule”, “No-Divider Mandate”)
- A controlled palette (primary/secondary/tertiary + surfaces) and softened contrast (avoid pure black)
- Typography pairing: Plus Jakarta Sans (display) + Manrope (body/label)
- Limited elevation: avoid traditional drop shadows; allow only soft ambient shadow for overlays when needed
- Primary CTAs may use a subtle gradient; glass/blur may be used for floating navigation/CTAs

The goal is to translate this into a maintainable Flutter foundation that can be consumed by all future features without duplicating styling logic.

## Goals / Non-Goals

**Goals:**

- Establish a token-driven theming foundation under `lib/share/`:
  - Colors, typography, spacing, radius (and minimal elevation/shadow guidance)
- Provide a base `ThemeData` built from those tokens and wired into the app entrypoint
- Provide a small set of shared primitives that encode the design rules (surfaces/cards, buttons, inputs)
- Make it easy for feature UI to stay compliant (no ad-hoc raw hex / spacing in feature views)

**Non-Goals:**

- Full implementation of all Stitch screens (e.g., “Add Expense”) in Flutter
- Completing navigation/routing architecture (`auto_route`) beyond what’s necessary for theme bootstrapping
- Building feature modules (transactions/accounts/etc.) as part of this change

## Decisions

1. **Token source of truth lives in `lib/share/tokens/`**

- **Decision**: All numeric values that would otherwise become “raw px” (e.g., 8, 16) and all palette hex values live only in token files.
- **Rationale**: Enforces the strict spec while allowing consistent reuse.
- **Alternative**: Inline constants inside feature widgets → rejected (violates token-first).

1. **Use a structured token API, not raw `Color` constants sprinkled in widgets**

- **Decision**: Expose tokens through a single `AppTokens`/`AppColors`/`AppTypography` surface that is easy to import and hard to misuse.
- **Rationale**: Keeps feature code simple and consistent, reduces drift.
- **Alternative**: Use Flutter’s `ColorScheme` only → insufficient to express surface hierarchy and component-specific rules.

1. **ThemeData is derived from tokens and becomes the default app theme**

- **Decision**: Create `lib/share/theme/app_theme.dart` that builds `ThemeData` using `ColorScheme` + component themes (input, buttons, app bar, etc.) wired to tokens.
- **Rationale**: Centralizes styling; keeps widgets aligned with the design system by default.
- **Alternative**: Theme per feature → rejected (cross-feature inconsistency).

1. **Shared primitives encode “no divider/border” rules**

- **Decision**: Provide shared widgets (e.g., `AppCard`, `AppSection`, `PrimaryCtaButton`, `AppTextField`) under `lib/share/widgets/` and encourage features to use them.
- **Rationale**: Some design rules can’t be reliably enforced by ThemeData alone.
- **Alternative**: Rely exclusively on theme configuration → rejected (doesn’t prevent ad-hoc dividers/borders).

1. **Fonts**

- **Decision**: Add Plus Jakarta Sans and Manrope as app fonts (via `pubspec.yaml`) and wire them through the theme’s `TextTheme`.
- **Rationale**: Matches Stitch design system and ensures typographic consistency.
- **Alternative**: Keep default fonts → rejected (diverges from design system).

## Risks / Trade-offs

- **[Risk] Token-first enforcement is social, not compiler-enforced** → **Mitigation**: shared primitives + consistent imports; optional linting/rules can be added later.
- **[Risk] Gradient/glass effects diverge across platforms** → **Mitigation**: implement as shared widgets with defined parameters; keep effects subtle.
- **[Risk] Over-engineering too early** → **Mitigation**: keep the initial primitive set small (surfaces, button, input) and expand only when features need it.