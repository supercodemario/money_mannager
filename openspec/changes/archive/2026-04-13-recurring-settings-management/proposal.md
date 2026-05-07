## Why

Users need a single place under Settings to see every recurring template, pause them without deleting history, and jump to add/edit/delete flows. Today the Recurring settings card is inert, templates always appear in Expenses → Recurring and on the home dashboard, and there is no way to “turn off” a bill that should not surface until re-enabled.

## What Changes

- Persist an **enabled** (or equivalent) flag on each recurring template with **default true** on migration.
- **Recurring templates management** screen opened from the Settings **Recurring** summary card: lists **all** templates, **enable/disable** switch per row, **edit** and **delete** actions, and a **floating action button** to open the existing add-recurring flow.
- When a template is **disabled**, it **disappears immediately** from the Expenses tab **Recurring payments** list and from the **home** overdue/upcoming sections, even if still **unpaid** for the current month.
- **Paid** fulfillments for past or current months **remain** (linked expense and occurrence unchanged); disabling does not “un-pay.”
- **Repository / queries**: operational surfaces (home + Expenses Recurring) use only **enabled** templates; the management screen uses an **all templates** query (or equivalent).

## Capabilities

### New Capabilities

- _(none — behavior is split across existing capabilities below)_

### Modified Capabilities

- `recurring-payments`: Add persisted scheduling-enabled state; clarify that Expenses Recurring and home lists show only enabled templates; preserve paid history when disabled; immediate hide behavior.
- `settings-compact-screen`: Recurring summary card **navigates** to the new management screen; specify that screen’s list, toggles, edit/delete, and FAB to add (reusing existing add-recurring implementation).

## Impact

- **Drift schema** (`RecurringPayments`), migration, `app_database.g.dart` regeneration.
- **`RecurringPaymentRepository`**: filter `watchRowsForMonth` / `watchHomeSections` (or callers) for enabled-only; add `watchAllTemplates` (or similar) and `setTemplateEnabled` / `updateTemplate`; possible **new** `updateTemplate` API if edit-from-settings is not yet supported.
- **`AddRecurringPaymentScreen`**: likely extended to support **edit** (optional template id / pre-filled fields) if not already present.
- **Navigation**: `SettingsScreen` Recurring card `onTap`, new route/screen under `lib/features/settings/` (or shared location per project conventions).
- **`AppStrings`** (or equivalent) for management screen title, accessibility labels for switches, empty state if needed.
