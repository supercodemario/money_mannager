## 1. Data model and migration

- [x] 1.1 Add category bucket field with allowed values (`needs`, `wants`, `savings_debt`) in local persistence models.
- [x] 1.2 Add migration/backfill logic to assign deterministic default buckets to existing categories.
- [x] 1.3 Update repositories/data access so category bucket can be read and updated from category management flows.

## 2. Preferences details and category listing UX

- [x] 2.1 Create preferences details screen and wire Settings Preferences card navigation to it.
- [x] 2.2 Add regional preference controls (Currency, Language, Number Format) in preferences details with local persistence.
- [x] 2.3 Add category listing management entry + screen showing categories and bucket assignment controls.

## 3. Expense flow classification integration

- [x] 3.1 Ensure add-expense category selection automatically resolves 50/30/20 bucket from selected category.
- [x] 3.2 Persist/propagate category bucket classification for new expenses without additional user input.
- [x] 3.3 Verify category bucket updates affect subsequent (future) expense classification behavior.

## 4. Verification

- [x] 4.1 Run `dart analyze` on touched files and resolve issues.
- [x] 4.2 Validate migration/backfill behavior on existing local data set.
- [x] 4.3 Sanity-check end-to-end: update category bucket → add expense with category → confirm expected bucket classification path.
