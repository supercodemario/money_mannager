## Context

`PreferencesDetailsScreen` already loads and saves `currencyCode`, `languageCode`, and `numberFormat` via `UserPreferencesRepository` (Drift `userPreferences` table, including `watchForUser`). The app root uses a static `MaterialApp` with no `locale`, and many screens hardcode USD (`$`, `formatExpenseUsdMinor` in `expenses_amount_format.dart`). `AppServices` does not notify descendants when preferences change, so even after save, other routes may keep stale symbols until a full restart.

## Goals / Non-Goals

**Goals:**

- Treat stored regional preferences as the **single source of truth** for (1) Flutter `Locale` / `MaterialApp` internationalization, (2) **currency symbol and money display** from integer minor units, and (3) **digit grouping and decimal separators** consistent with the saved number-format preset.
- Ensure updating preferences **propagates** to the widget tree so amounts and locale refresh **without requiring an app restart**.

**Non-Goals:**

- Translating all `AppStrings` into es/fr (language selection may switch `Locale` first; full translations can follow separately).
- Changing how amounts are **stored** (`amount_minor` remains minor units of the **accounting currency** — assumed stable per user; FX conversion between currencies is out of scope unless already modeled).

## Decisions

1. **Preference propagation — `watchForUser` at the shell**  
   **Choice**: Subscribe to `UserPreferencesRepository.watchForUser(userId)` from a widget **above** most of the app (e.g. wrap `MaterialApp`’s `home` subtree or rebuild `MaterialApp` when the stream emits).  
   **Rationale**: Repository already exposes a stream; avoids polling and keeps UI in sync after `upsertForUser` from Preferences.  
   **Alternative**: `ChangeNotifier` in `AppServices` — rejected for now to avoid duplicating state already in Drift.

2. **Expose formatting via a small scope API**  
   **Choice**: Add something like `RegionalFormattingScope` / `InheritedWidget` (or explicit optional parameter object) built from latest `UserPreference` row providing `Locale locale`, `String formatMinor(int minor)`, and `String currencySymbol` or reuse `NumberFormat` instances cached per locale+currency+preset.  
   **Rationale**: Screens depend on one abstraction instead of importing `intl` everywhere.  
   **Alternative**: Pass `UserPreference` through constructors — rejected as too invasive across features.

3. **`Locale` mapping**  
   **Choice**: Map stored `languageCode` (`en`, `es`, `fr`) to `Locale(languageCode)` or `Locale(languageCode, region)` where needed for number patterns; document defaults when Flutter lacks delegates for a locale (fallback `Locale('en')`).  
   **Rationale**: Minimal change to existing persisted codes.

4. **Number format presets (`us` / `eu` / `in`)**  
   **Choice**: Map each preset to `NumberFormat` / pattern parameters (decimal and group separators) when formatting minor units, combined with `NumberFormat.simpleCurrency` (or `currency` + custom pattern) for the **selected currency code**.  
   **Rationale**: Matches existing persisted enum-like strings on the screen.

5. **Refactor call sites**  
   **Choice**: Replace hardcoded `$` and `formatExpenseUsdMinor` usages with the scope helper; keep `parseUsdMinorFromString` behavior compatible but optionally rename to neutral **minor parsing** that respects decimal separator from preset for input fields.

## Risks / Trade-offs

- **[Risk] Incomplete locale coverage** — Some Flutter locales may miss translations; UI strings can stay English while `Locale` still affects date/number formats. **Mitigation**: Document fallback; use `supportedLocales` intentionally.  
- **[Risk] Storing one currency while historical data used another** — User could switch currency and see the same minor integers with a new symbol. **Mitigation**: Document that this is **display** currency; no historical FX in v1.  
- **[Risk] Every format call allocates `NumberFormat`** — **Mitigation**: Cache formatters in the scope when preference snapshot is stable; invalidate on stream update.

## Migration Plan

1. Land shared scope + root subscription; default to current behavior (USD / `en` / `us`) when no row exists.  
2. Migrate screens incrementally from hardcoded USD to the scope (search for `$`, `formatExpenseUsdMinor`, and `r'$'`).  
3. No server migration: local DB schema already supports preferences.

## Open Questions

- Whether **input** fields (Quick Add, Add Expense) should use **currency symbol** from prefs only, or also **swap** parser for `,` vs `.` based on number format (recommend: yes for EU users).  
- Whether to add `localizationsDelegates` for `es`/`fr` if more than `DefaultMaterialLocalizations` is required for Material widgets.
