## ADDED Requirements

### Requirement: Token-first design system foundation

The system MUST provide a token-first design system under `lib/share/tokens/` that defines the canonical values for:

- color palette and surface hierarchy
- typography scale and font families
- spacing scale
- corner radius scale

#### Scenario: Feature UI consumes tokens, not literals

- **WHEN** a feature screen is implemented under `lib/features/<feature>/view/`
- **THEN** the UI SHALL reference shared tokens (e.g., colors/spacing/typography) rather than using raw hex color literals or raw numeric spacing constants directly in the feature view code

### Requirement: Base ThemeData is centralized and token-driven

The system MUST provide a centralized base theme builder (Flutter `ThemeData`) that is derived from the shared tokens and can be applied globally by the app.

#### Scenario: App entrypoint applies base theme

- **WHEN** the application starts
- **THEN** the root `MaterialApp` (or router equivalent) SHALL use the base theme as its default theme

### Requirement: Shared primitives encode design rules

The system MUST provide shared UI primitives under `lib/share/widgets/` that encode the core design rules from the Stitch design system (e.g., tonal layering over borders/dividers, consistent surfaces/cards, and standardized primary/secondary/tertiary actions).

#### Scenario: Feature uses shared primitives for common UI elements

- **WHEN** a feature implements a card, a primary call-to-action button, or an input field
- **THEN** the feature SHOULD prefer using the shared primitives rather than re-implementing ad-hoc styling per feature

### Requirement: Design system typography is applied

The system MUST configure the app typography so that display/headline styles and body/label styles align with the design system’s font pairing (Plus Jakarta Sans for display/headline; Manrope for body/label).

#### Scenario: Default text styles use configured fonts

- **WHEN** a screen renders headline and body text using the app’s `TextTheme`
- **THEN** the rendered fonts SHALL match the configured design system fonts for those text roles