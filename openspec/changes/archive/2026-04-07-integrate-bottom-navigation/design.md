## Context

The Stitch “Refined Dashboard” screen uses a bottom navigation bar with:

- Translucent surface (`~80%` opacity) + `backdrop-blur` (glassmorphism)
- Strong top rounding (`1.5rem` → aligns to `AppRadius.xl`)
- Soft ambient shadow upward (large blur, ~6% opacity) consistent with the design system’s “Ambient Softness” rule
- 5 primary destinations (Home, Expenses, Add, Insights, Settings)
- An emphasized active tab (tile/gradient) and a prominent center “Add” action

The project also enforces strict structure and token-first UI:

- No cross-feature imports
- Shared UI belongs in `lib/share/`
- Feature views must avoid hardcoded strings and raw styling literals

## Goals / Non-Goals

**Goals:**

- Implement a reusable bottom navigation shell that hosts the primary sections of the app
- Encode the “glass” bottom nav look using tokens (colors, spacing, radius) and shared widgets where appropriate
- Standardize tab labels through `AppStrings` and keep the shell feature isolated

**Non-Goals:**

- Implement full Expenses/Insights/Settings features (placeholders are acceptable until those features exist)
- Implement routing (`auto_route`) composition beyond what is needed for the shell; routing integration can be a follow-up change

## Decisions

1. **Shell as a feature (`lib/features/shell/`)**

- **Decision**: Bottom navigation lives in a dedicated shell feature to avoid cross-feature dependencies and keep the app root simple.
- **Alternative**: Put navigation directly in `main.dart` → rejected (harder to evolve, violates feature-first conventions).

1. **Use `IndexedStack` for tab state preservation**

- **Decision**: Render tab bodies via `IndexedStack` so each tab preserves scroll/state.
- **Alternative**: Replace body with conditional widget → rejected (state resets on tab switch).

1. **Token-driven glass styling**

- **Decision**: Use `BackdropFilter` blur + translucent `AppColors.surface` and an ambient shadow derived from `AppColors.onSurface` with low opacity.
- **Alternative**: Standard `BottomNavigationBar` → rejected (harder to match Stitch glass + active tile).

1. **Strings via `AppStrings`**

- **Decision**: Tab labels and titles are centralized under `lib/share/tokens/app_strings.dart`.
- **Alternative**: Hardcoded strings in the shell/feature views → rejected.

## Risks / Trade-offs

- **[Risk] Platform differences for blur** → **Mitigation**: keep blur subtle and fallback to translucent surface if needed.
- **[Risk] Navigation architecture will change with `auto_route`** → **Mitigation**: keep shell API small so it can be adapted to router-based navigation later.