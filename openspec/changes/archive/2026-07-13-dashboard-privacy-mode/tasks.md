## 1. Persistence and app wiring

- [x] 1.1 Add `PrivacyModePreferences` (SharedPreferences get/set for `privacy_mode_enabled`, default false)
- [x] 1.2 Add a `ValueNotifier<bool>` (or thin store) on `AppServices`, load initial value at bootstrap, expose update that writes prefs + notifies
- [x] 1.3 Add Settings / a11y strings for Privacy mode title, subtitle, and show/hide balances semantics

## 2. Settings UI

- [x] 2.1 Add Privacy mode switch on `SettingsScreen` bound to the notifier (persist on change; do not couple to Home reveal)

## 3. Home masking and reveal

- [x] 3.1 Add helper to format amount as normal or `{currencySymbol} •••••` from privacy + temporary reveal flags
- [x] 3.2 Own `_temporarilyRevealed` on Home expense tree; clear on leave Home / tab hide and on app background (`WidgetsBindingObserver`)
- [x] 3.3 Wire `DashboardBudgetHero`: mask Total family budget; show eye only when privacy on; eye toggles temporary reveal
- [x] 3.4 Wire `DashboardMonthlySpendingCard`: mask only spent amount, savings, and monthly remaining/overspent; leave indicative daily, %, subtitles, bills unchanged

## 4. Verification

- [x] 4.1 Manually verify: privacy on → four masked; eye reveals all four; Settings switch stays on; leave Home / background re-masks; privacy off → normal + no eye; restart keeps preference
