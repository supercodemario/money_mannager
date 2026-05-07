## Why

Users need meaningful budgeting insights aligned to the 50/30/20 rule, but categories currently do not carry bucket metadata. Adding category-to-bucket mapping now enables automatic classification during expense entry and creates a stable foundation for later insights visualizations.

## What Changes

- Introduce category bucket mapping for the 50/30/20 model:
  - `needs` (50%),
  - `wants` (30%),
  - `savings_debt` (20%).
- Provide a category listing/management screen where each category is assigned to one of the three buckets.
- Ensure add-expense flow automatically derives the 50/30/20 bucket from selected category (no extra user input while adding expense).
- Scope this phase to category setup and automatic classification only; defer insights progress bars to a later phase.

## Capabilities

### New Capabilities

- `category-bucket-management`: Manage categories with required 50/30/20 bucket assignment and category listing operations.

### Modified Capabilities

- `expenses-tab`: Expense creation and related category selection behavior classify entries automatically via category bucket mapping.
- `settings-compact-screen`: Preferences card opens a dedicated preferences details screen containing regional preferences and category listing entry points.

## Impact

- Affected code: category/domain models, category list UI, preferences details UI, add expense flow, and related repositories/database tables.
- Data impact: existing categories require bucket backfill/migration defaults.
- No external API dependencies; local persistence changes are expected.