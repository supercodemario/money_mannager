## Context

Home shows Total family budget (`DashboardBudgetHero`) and Monthly spending / remaining / savings (`DashboardMonthlySpendingCard`) as clear currency amounts. Settings already has toggle-style rows (biometric, push) but those are in-memory only. Device-local prefs already use SharedPreferences via `OnboardingPreferences`. Amount formatting goes through `formatExpenseMinor` / regional currency symbol.

This change adds a real persisted Privacy mode preference and Home-only temporary reveal, without syncing to Drift or the cloud.

## Goals / Non-Goals

**Goals:**

- Persist Privacy mode on/off with SharedPreferences.
- Mask exactly four Home amounts when enabled and not temporarily revealed.
- Provide an eye control on the budget hero that peeks all four amounts.
- Clear peek when leaving Home or when the app backgrounds; never write peek state back to Settings.
- Keep Settings as the only writer of the persisted preference.

**Non-Goals:**

- Masking indicative daily, progress %, subtitles, overspent amount labels, upcoming bills, Expenses tab, or other screens.
- Syncing privacy mode across devices / family members.
- Biometric gate before reveal.
- Persisting temporary reveal across navigation or process death.
- Changing biometric/push toggles to also persist (out of scope).

## Decisions

### 1. Storage: SharedPreferences (not Drift `UserPreferences`)

- **Choice**: New small helper (e.g. `PrivacyModePreferences`) mirroring `OnboardingPreferences`, key like `privacy_mode_enabled`, default `false`.
- **Why**: Device UI preference; must not sync with household/cloud; no schema migration.
- **Alternatives**: Drift column (overkill, risk of future sync); secure storage (unnecessary for a bool).

### 2. Cross-screen updates: lightweight listenable, not Cubit

- **Choice**: Expose a `ValueNotifier<bool>` (or equivalent thin store) from `AppServices` that loads from SharedPreferences and is updated when Settings toggles. Home and Settings listen via `ValueListenableBuilder` / `ListenableBuilder`.
- **Why**: Settings must update Home while both are alive; ChangeNotifier/Cubit are optional ceremony—`ValueNotifier` matches Flutter primitives and is lighter than `CloudSyncController`-style ChangeNotifier.
- **Alternatives**: Cubit (heavy); read prefs only on rebuild (Settings→Home lag); InheritedWidget-only (more boilerplate for one bool).

### 3. Temporary reveal: Home-owned ephemeral state

- **Choice**: `bool _temporarilyRevealed` on the Home expense tree (e.g. `DashboardHomeScreen` or a small wrapper around expense body). Pass `masked` / `revealed` down to hero + spending card (or a shared `PrivacyAmountDisplay` helper).
- **Why**: User clarified peek never updates Settings; reveal is session UX only.
- **Clear on**: disposing Home / switching away from Home tab; `AppLifecycleState.inactive` or `paused` via `WidgetsBindingObserver`.
- **Alternatives**: Global reveal flag (rejected—would couple Settings); timer-based auto-hide (not requested).

### 4. Mask format

- **Choice**: `{currencySymbol} •••••` using the active regional currency symbol (not hardcoded `₹`).
- **Why**: Agreed product format; stays consistent with `RegionalFormattingScope`.

### 5. Amount application points

- **Choice**: Central helper e.g. `privacyAwareExpenseAmount(context, minor, {required bool privacyEnabled, required bool temporarilyRevealed})` used only at the four call sites (budget hero value; spent this month; savings pill; monthly remaining/overspent value in the balance row).
- **Why**: Avoid inconsistent masking; keep non-scoped labels (%, indicative daily, bills) untouched.

### 6. Settings UI placement

- **Choice**: New toggle row on `SettingsScreen`, grouped with existing security/notification toggles (near biometric).
- **Why**: User asked for Settings switch; biometric cluster is the natural “privacy/security” area.

### 7. Eye icon UX

- **Choice**: Visible only when `privacyEnabled`; placed beside the Total family budget label/value row; toggles `_temporarilyRevealed`; semantics label for show/hide balances.
- **Why**: Single affordance reveals all four amounts as specified.

## Risks / Trade-offs

- **[Risk] Tab navigation**: If Home State is kept alive under an `IndexedStack`, “leave Home” must clear reveal on tab change, not only on dispose. → Clear reveal when the Home tab loses visibility (listen to parent tabs router / `Visibility` / tab index).
- **[Risk] Lifecycle**: Aggressive clear on `inactive` may hide amounts during system permission sheets. → Prefer `paused` if `inactive` proves noisy; document in implementation.
- **[Risk] Partial masking**: Progress % and subtitles still leak rough magnitude. → Accepted non-goal; can extend later.
- **[Trade-off] ValueNotifier on AppServices**: Global for a UI preference. → Acceptable; same pattern as other app-wide services; keeps Settings→Home live updates simple.

## Migration Plan

- Default `privacy_mode_enabled = false` → no behavior change for existing users until they enable it.
- No data migration, no remote config.
- Rollback: remove switch + masking helpers; leftover prefs key is harmless.

## Open Questions

- None blocking. Implementation may choose `paused` vs `inactive` for lifecycle clear after a quick device check.
