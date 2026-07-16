## Why

Users already get bank and UPI payment SMS on Android but still re-type amount and merchant into HomeRatio. Surfacing India payment SMS on the Home dashboard and one-tap prefilling the regular Add Expense screen cuts friction for the most common expense-entry path—without syncing message content off the device.

## What Changes

- Add an Android-only **Payment SMS** section on Dashboard Home that lists recent India debit/payment messages parsed from the device inbox.
- Request SMS read permission via an in-app explain dialog (clear purpose + privacy: on-device only, never synced), then the system permission prompt.
- Each list row offers **Add to expense**, which opens the regular Add Expense screen with amount and note (and date when available) prefilled; the user selects category and saves.
- After a successful save, mark that SMS as handled **locally** and remove it from the Home list so it does not reappear.
- Hide the entire SMS section on non-Android platforms.
- Do **not** sync SMS bodies, sender addresses, or handled-SMS state to Supabase or any remote store.

## Capabilities

### New Capabilities

- `android-sms-payment-expenses`: Android-only Home list of India payment SMS, permission UX, on-device parsing, handoff to Add Expense, and local handled-state so added items leave the list—with no cloud sync of messages.

### Modified Capabilities

- `add-expense-ui`: Regular Add Expense screen MUST accept optional initial amount, note, and date so SMS (and future sources) can prefill fields while the user still chooses category and confirms save.

## Impact

- **UI**: `DashboardHomeScreen` / `DashboardHomeExpenseBody` gains a Payment SMS card/section (Android); `AddExpenseScreen` gains optional prefill constructor/route args.
- **New feature module**: Likely `lib/features/sms_payments/` (or equivalent) for inbox read, India debit parsing, permission + list bloc, and Home widget—respecting feature isolation.
- **Local storage**: Device-only store for permission prompt dismissal and handled SMS keys (e.g. SharedPreferences); no Drift/Supabase tables for SMS content.
- **Platform**: Android `READ_SMS` (and related) manifest permission; runtime permission via a Flutter SMS/telephony package; iOS builds must compile and simply omit the section.
- **Play Store**: SMS is a sensitive permission—copy and use-case must stay limited to payment-expense suggestion on device.
- **Deps**: New Android SMS-reading package + likely `permission_handler` (or package-equivalent); string tokens in `AppStrings`.
