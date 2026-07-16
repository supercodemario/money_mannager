## 1. Dependencies and platform

- [x] 1.1 Add Android SMS inbox + permission dependencies to `pubspec.yaml` (package choice per design spike) and run pub get
- [x] 1.2 Declare `READ_SMS` (and any package-required) permissions in `android/app/src/main/AndroidManifest.xml`
- [x] 1.3 Confirm iOS build still succeeds with SMS code gated behind `Platform.isAndroid`

## 2. Shared prefill and Add Expense

- [x] 2.1 Add a shared `ExpensePrefill` (or equivalent) DTO under `lib/share/` or `lib/core/` with amount, note, optional date, optional source key
- [x] 2.2 Extend `AddExpenseScreen` to accept optional initial amount, note, and date and seed controllers/state
- [x] 2.3 Wire shell / navigation so Home can open regular Add Expense with prefill without `sms_payments` importing `add_expense` (callback or route args via app layer)
- [x] 2.4 On successful save when a source SMS key is present, invoke a callback/notifier so the SMS feature can mark handled

## 3. SMS feature data layer

- [x] 3.1 Scaffold `lib/features/sms_payments/` (`data/`, `models/`, `bloc/`, `view/`) per project structure
- [x] 3.2 Implement device-local prefs helper for explain-dialog state and handled SMS key set (SharedPreferences; no sync)
- [x] 3.3 Implement inbox reader wrapper (Android-only) that returns recent messages with stable ids
- [x] 3.4 Implement India debit/payment parser (amount, note, date) with unit tests for sample UPI/bank debit and OTP exclusion cases
- [x] 3.5 Implement repository that loads candidates, filters handled keys, and marks handled after save

## 4. Permission and list state

- [x] 4.1 Add `AppStrings` (and any needed tokens) for section title, Add to expense, explain dialog body/actions, denied CTA, empty state
- [x] 4.2 Implement cubit/bloc for permission status, explain-dialog flow, load/refresh list, and mark-handled
- [x] 4.3 Build explain `AlertDialog` (Not now / Allow) then system permission request; persist dismissal to avoid spam
- [x] 4.4 Build denied/missing-permission CTA UI in the section

## 5. Home UI integration

- [x] 5.1 Build Payment SMS section widget (rows: amount, note/label, Add to expense) using design tokens
- [x] 5.2 Embed section in `DashboardHomeExpenseBody` under budget hero, only when `Platform.isAndroid` and expense Home is shown
- [x] 5.3 Refresh list when Home becomes visible and after a successful SMS-sourced expense save
- [x] 5.4 Cap visible rows (e.g. max 8) and show empty/handled-empty state when no candidates remain

## 6. Verification

- [x] 6.1 Manual Android pass: explain dialog → grant → list → Add to expense prefill → save → row gone; deny path shows CTA
- [x] 6.2 Confirm no SMS content or handled keys are written to Drift sync / Supabase paths
- [x] 6.3 Run unit tests for parser and any prefill widget tests; smoke iOS that section is absent
