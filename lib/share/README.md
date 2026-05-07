## `lib/share/`

This module contains **shared design system foundations** and reusable UI primitives.

### Token-first rule

Feature UI under `lib/features/*/view/` MUST NOT use:
- raw hex colors (e.g. `#ffffff`)
- raw numeric spacing/radius constants (e.g. `16.0`, `8.0`)

Instead, feature UI SHOULD use:
- tokens from `lib/share/tokens/` (e.g. `AppColors.surface`, `AppSpacing.s16`)
- shared primitives from `lib/share/widgets/` when available (e.g. `AppCard`, `AppPrimaryButton`)

