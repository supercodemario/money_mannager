## 1. Foundations (structure + dependencies)

- [x] 1.1 Create the required `lib/share/` subfolders (`tokens/`, `theme/`, `widgets/`, `assets/`) and align `lib/` with `features/`, `core/`, `share/`
- [x] 1.2 Add required dependencies and assets for fonts (Plus Jakarta Sans, Manrope) and any theming helpers; ensure `flutter pub get` succeeds

## 2. Tokens (single source of truth)

- [x] 2.1 Implement color tokens mapped from the Stitch design system (`surface`, `surface-container-*`, `primary`, `secondary`, `tertiary`, `on-*`, `outline*`, etc.)
- [x] 2.2 Implement typography tokens (font families + text styles / scale) aligned to the design system pairing
- [x] 2.3 Implement spacing + radius tokens (including interpretation of `ROUND_EIGHT` and “xl (1.5rem)” radius usage)

## 3. ThemeData (token-driven base theme)

- [x] 3.1 Implement a centralized theme builder (`ThemeData`) derived from tokens (ColorScheme + component themes)
- [x] 3.2 Wire the base theme into `lib/main.dart` so the app uses it by default

## 4. Shared primitives (encode design rules)

- [x] 4.1 Add shared surface/card primitives that follow “no-line / tonal layering” (no default borders/dividers)
- [x] 4.2 Add shared button primitives including a primary CTA with the design system’s gradient rule
- [x] 4.3 Add shared input primitives following the filled style + bottom-only focus indicator rule

## 5. Guardrails (keep features compliant)

- [x] 5.1 Add lightweight guidance/readme in `lib/share/` (or equivalent) describing token-first usage and where to put shared UI primitives
- [x] 5.2 Update the default widget test (if needed) to use the new app root theme/bootstrap without failing