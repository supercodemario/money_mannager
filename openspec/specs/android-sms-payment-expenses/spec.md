# android-sms-payment-expenses Specification

## Purpose

On Android, surface India payment/debit SMS on Home so users can one-tap into Quick Add with amount and note prefilled. Messages stay on-device (never synced). Users control the feature via a launch permission flow and a Settings toggle.

## Requirements

### Requirement: Android Home shows India payment SMS list

On Android, when Dashboard Home is showing the expense dashboard (not the first-run tutorial), the system MUST show a Payment SMS section listing recent India payment/debit SMS candidates parsed from the device inbox when SMS read is enabled and candidates exist. On non-Android platforms, the system MUST NOT show this section.

#### Scenario: Android user with permission sees payment SMS rows

- **WHEN** the user is on Dashboard Home on Android and SMS read is enabled with granted permission and matching inbox candidates
- **THEN** the app SHALL display a Payment SMS section with one or more rows derived from India debit/payment SMS (amount and a short note/label)

#### Scenario: Empty list hides the section

- **WHEN** SMS read is enabled but there are no unhandled payment SMS candidates
- **THEN** the app SHALL NOT display the Payment SMS section

#### Scenario: Non-Android hides the section

- **WHEN** the user is on Dashboard Home on a non-Android platform
- **THEN** the app SHALL NOT display the Payment SMS section

### Requirement: Explain dialog before requesting SMS permission

Before the first system SMS permission prompt for this feature, the system MUST show an in-app dialog that explains that payment SMS are read on this device only to suggest expenses and are never synced. The dialog MUST offer a dismiss action and an allow action that proceeds to the system permission request. On Android, this dialog MUST be offered when Home first loads (including the first-run tutorial), and MUST NOT require the user to have added an expense first.

#### Scenario: First Home visit shows explain dialog

- **WHEN** an Android user reaches Home for the first time and has not yet completed the explain dialog for SMS access
- **THEN** the app SHALL show the explain dialog with dismiss and allow actions
- **AND** the app SHALL NOT require a prior expense or completed onboarding tutorial to show this dialog

#### Scenario: Allow proceeds to system permission

- **WHEN** the user taps allow on the explain dialog
- **THEN** the app SHALL request the platform SMS read permission

#### Scenario: Dismiss does not spam

- **WHEN** the user dismisses the explain dialog without allowing
- **THEN** the app SHALL NOT re-show the same explain dialog on every Home rebuild (it MAY offer a later CTA via Settings to enable access)

### Requirement: Settings toggle for SMS read

On Android, Settings MUST provide a toggle to turn Payment SMS reading on or off. Turning the feature off MUST stop showing Payment SMS on Home. Turning the feature on MUST enable reading when SMS permission is granted; if permission was previously denied, the app MUST open the Android app permission settings screen so the user can grant SMS access.

#### Scenario: Turn SMS read off

- **WHEN** the user turns off Read payment SMS in Settings
- **THEN** the app SHALL hide the Payment SMS list on Home

#### Scenario: Turn SMS read on with permission already granted

- **WHEN** the user turns on Read payment SMS and SMS permission is already granted
- **THEN** the app SHALL enable Payment SMS reading

#### Scenario: Turn SMS read on after prior denial

- **WHEN** the user turns on Read payment SMS and SMS permission was previously denied
- **THEN** the app SHALL open the Android application settings screen for granting SMS permission

### Requirement: Add to expense prefills Quick Add

Each eligible Payment SMS row MUST provide an Add to expense action that opens the same Quick Add (New Expense) experience used by the Home FAB / Add tab, with amount and note prefilled from the parsed SMS (and date when available). The user MUST still select a category and confirm save.

#### Scenario: User taps Add to expense

- **WHEN** the user taps Add to expense on a Payment SMS row
- **THEN** the app SHALL open Quick Add with amount and note prefilled from that SMS
- **AND** the user SHALL still choose a category before a successful save

### Requirement: Handled SMS leave the Home list locally

After the user successfully saves an expense created from a Payment SMS row, the system MUST mark that SMS as handled in device-local storage only and MUST remove it from the Payment SMS list. The system MUST NOT sync SMS content or handled-SMS state to remote storage.

#### Scenario: Successful save hides the row

- **WHEN** the user saves an expense started from a Payment SMS row
- **THEN** that SMS row SHALL no longer appear in the Payment SMS list on subsequent Home loads on that device

#### Scenario: No remote sync of SMS

- **WHEN** the app processes Payment SMS or marks a SMS as handled
- **THEN** the app SHALL NOT upload SMS bodies, sender addresses, or handled-SMS keys to Supabase or other remote sync paths

### Requirement: India debit-oriented filtering

The Payment SMS list MUST only include messages that look like India payment/debit notifications with a parseable amount. The list MUST NOT treat OTPs or generic balance/promo messages as expense candidates.

#### Scenario: Debit SMS is listed

- **WHEN** an inbox message matches India debit/payment patterns and contains a parseable amount
- **THEN** the app SHALL include it as a Payment SMS candidate (unless already handled)

#### Scenario: OTP is excluded

- **WHEN** an inbox message is an OTP or lacks a payment amount
- **THEN** the app SHALL NOT show it as a Payment SMS expense candidate

### Requirement: Token-first UI and centralized strings

Payment SMS UI MUST use shared design tokens and centralized string tokens for user-visible copy (including permission dialog text).

#### Scenario: Strings and tokens

- **WHEN** the Payment SMS section or permission dialog is rendered
- **THEN** visible labels SHALL come from `AppStrings` (or equivalent centralized strings) and styling SHALL use `lib/share/tokens/`
