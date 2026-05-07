## 1. Data layer

- [x] 1.1 Add `isEnabled` (or agreed name) boolean to `RecurringPayments` in `app_database.dart` with default **true**; bump schema version and implement migration for existing installs.
- [x] 1.2 Regenerate Drift code (`dart run build_runner build` or project-standard command) and fix any compile breaks.

## 2. Repository

- [x] 2.1 Add `setSchedulingEnabled(String templateId, bool enabled)` (or equivalent) updating `updatedAt`.
- [x] 2.2 Add `updateTemplate` (or extend companions) for fields edited from the add/edit screen; align with `insertTemplate` field set.
- [x] 2.3 Restrict `watchRowsForMonth` / `watchHomeSections` (or shared query builder) to **enabled** templates only; add `watchAllTemplates` (or similar) **without** that filter for the management screen.

## 3. Add / edit recurring UI

- [x] 3.1 Extend `AddRecurringPaymentScreen` to accept optional **existing template id** (or template model): pre-fill title, amount, category, due day, auto-recurring / end month; save path calls `updateTemplate` instead of `insertTemplate` when editing.
- [x] 3.2 Keep create flow unchanged when opened without template context (FAB from management screen).

## 4. Management screen and navigation

- [x] 4.1 Implement recurring templates management screen (list all templates, row switch → `setSchedulingEnabled`, edit/delete actions, loading/error states as needed).
- [x] 4.2 Wire Settings **Recurring** grid card `onTap` to push the management screen.
- [x] 4.3 Add FAB on management screen navigating to `AddRecurringPaymentScreen` for new template.
- [x] 4.4 Register route in app router/shell if the project uses centralized routes (match existing `AddRecurringPaymentScreen` pattern from Expenses).

## 5. Strings and polish

- [x] 5.1 Add `AppStrings` (or project standard) for management screen title, FAB tooltip if used, switch semantics / accessibility labels, and empty state if the list can be empty.
- [x] 5.2 Run `dart analyze` on touched paths; manually verify: disable removes row from Expenses Recurring and home immediately; paid month then disable keeps expense in Daily/Monthly; re-enable shows template again.
