## Context

The app currently uses category IDs for expenses and recurring templates, but categories do not encode budgeting intent for the 50/30/20 model. Users want to configure preferences (currency, language, number format) and manage categories in one details screen, while ensuring expense classification into Needs/Wants/Savings & Debt happens automatically at selection time.

Phase 1 scope is foundational: category bucket mapping + category listing management + preferences details navigation and regional selectors. Insights visualizations are intentionally deferred to a later change.

## Goals / Non-Goals

**Goals:**
- Introduce category-level bucket assignment (`needs`, `wants`, `savings_debt`) required for all categories.
- Provide a preferences details screen entry from Settings Preferences card with regional preferences (currency, language, number format) and category listing access.
- Ensure add-expense flow can infer 50/30/20 bucket from selected category without additional user input.
- Establish safe handling for existing categories via deterministic backfill/migration.

**Non-Goals:**
- No Insights tab progress bars in this phase.
- No cloud sync or multi-device preference reconciliation.
- No advanced budget recommendation logic beyond deterministic bucket classification.

## Decisions

1. **Category as source-of-truth for 50/30/20 bucket**
   - Each category stores exactly one bucket.
   - Alternative considered: assign bucket per expense entry; rejected due to repetitive UX and inconsistent analytics.

2. **Preferences details screen as integration hub**
   - Settings Preferences card opens a dedicated details screen for regional settings and category management entry.
   - Alternative considered: keep scattered toggles on root Settings; rejected due to discoverability and scaling concerns.

3. **Phase-1 category management supports listing + add/edit bucket mapping**
   - Keep operations focused and stable for initial rollout.
   - Deletion/hide semantics may be constrained for built-ins to avoid breaking historical references.

4. **Backfill existing categories during migration**
   - Apply deterministic default bucket mapping for current built-in categories.
   - Alternative considered: “unassigned” interim bucket; rejected because it weakens auto-classification guarantees.

## Risks / Trade-offs

- **[Risk] Historical data inconsistencies if categories are renamed/removed** → **Mitigation:** preserve stable category IDs and constrain destructive category operations.
- **[Risk] Migration mapping might misclassify some existing categories** → **Mitigation:** document defaults and allow user edits in category management.
- **[Risk] Regional preferences may not propagate to all formatting paths immediately** → **Mitigation:** wire preference reads in critical entry points first and add follow-up tasks for remaining surfaces.
- **[Trade-off] Additional setup complexity in preferences screen** → **Mitigation:** provide sensible defaults and clear section grouping.
