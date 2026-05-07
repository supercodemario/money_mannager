## 1. Dependencies and codegen

- [x] 1.1 Add Drift runtime packages (`drift`, `drift_flutter`, `sqlite3_flutter_libs`) and dev packages (`drift_dev`, `build_runner`) per current pub.dev compatibility
- [x] 1.2 Add `build.yaml` or Drift config if required by project layout; document `dart run build_runner build` (or watch) for generated files

## 2. Schema and database

- [x] 2.1 Define `user_profiles` per `design.md` (UUID `id`, `display_name`, `created_at`, `updated_at`; optional nullable fields as agreed)
- [x] 2.2 Define `expenses` Drift table with `created_by_user_id` referencing `user_profiles.id`, plus columns from `design.md` (`amount_minor`, `currency_code`, `category_id`, `note`, `occurred_at`, `created_at`, `updated_at`)
- [x] 2.3 Optionally add nullable sync-oriented columns on `expenses` (and profiles if in design) in the same migration to ease a future sync change
- [x] 2.4 Add indexes on `occurred_at`, `(category_id, occurred_at)`, and `created_by_user_id` as appropriate for reporting
- [x] 2.5 Implement `AppDatabase` with `@DriftDatabase` and migration strategy from version 1; seed **one** `user_profiles` row on first open if none exists

## 3. Repository layer

- [x] 3.1 Implement profile repository (or equivalent): get current user id, get/update display name, ensure bootstrap
- [x] 3.2 Implement expense repository with `insertExpense` including `created_by_user_id` from current profile; minor-unit integers end-to-end from UI parsing where applicable
- [x] 3.3 Expose at least one read path (e.g. `watchAll` or `listRecent`) for verification/tests

## 4. App integration

- [x] 4.1 Instantiate and provide the database singleton from app startup (or root scope) using the project’s chosen DI/state approach
- [x] 4.2 Wire Quick Add save affordance to `insertExpense` with selected date, note, category id, amount, and current user id; dismiss or reset UI on success per existing UX
- [x] 4.3 If Add Expense screen remains user-facing with save, wire the same expense repository path for consistency
- [x] 4.4 Add minimal UX to view or edit **display name** if required by spec (e.g. settings row or default-only bootstrap)

## 5. Verification

- [x] 5.1 Add tests that profile bootstrap runs once and that inserts include `created_by_user_id`
- [x] 5.2 Run `flutter test` and fix regressions

## 6. Roadmap note

**Do not implement** `family-expense-sync` in this change. Use `specs/family-expense-sync/spec.md` when opening a future proposal for multi-device sync.
