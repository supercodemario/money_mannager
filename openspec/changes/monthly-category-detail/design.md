## Context

The Expenses tab **Monthly** view (`MonthlyExpensesView`) streams `watchMonthlyCategoryTotals` and renders non-interactive category cards. **Daily** mode already lists individual expenses via `watchExpensesInRangeWithCreator` and `ExpenseTransactionRow`. Expenses persist `household_id` for multi-household sync; household **names** resolve from Supabase (`HouseholdRemoteGateway.fetchHouseholdDisplayName` / `fetchHouseholdsForCurrentUser`). There is no chart library in `pubspec.yaml` today.

## Goals / Non-Goals

**Goals:**

- Drill-down from a Monthly category row to a detail screen with **Transactions** and **Trend** tabs.
- **Transactions**: organized `AppCard` rows—amount and date on the primary line; `Paid by · {name}` and `Family · {label}` on secondary lines; optional note.
- **Trend**: line chart of **daily** category spend for the **selected calendar month** (local boundaries, consistent with existing month stepper).
- Month stepper on the detail screen (same `DateStepperPill` pattern as Expenses parent).
- Data from local Drift via new repository methods; reactive `Stream` updates.

**Non-Goals:**

- Editing or deleting expenses from detail (list-only v1).
- Multi-month trend charts (12-month history).
- Per-row tap actions, export, or budget comparisons.
- Changing Daily or Recurring mode behavior.
- Caching household names in a new SQLite table (v1 uses in-memory map from household list fetch).

## Decisions

### 1) Navigation: `MaterialPageRoute` push from Monthly row tap

**Decision:** Push `MonthlyCategoryDetailScreen` with `categoryId`, initial `month`, and category metadata (label/icon from `defaultExpenseCategories`).

**Rationale:** Matches existing Expenses navigation (`AddRecurringPaymentScreen`); no new auto_route registration required for v1.

**Alternative:** Register `@RoutePage` — rejected for scope; can migrate later.

### 2) Detail tabs: two-segment pill (not Material `TabBar`)

**Decision:** Reuse the visual pattern of `_ExpensesModePillTabs` with two segments: **Transactions** | **Trend**.

**Rationale:** Consistent with Expenses mode switcher; avoids introducing a different tab chrome.

### 3) Transactions layout: organized cards (not `DataTable`)

**Decision:** One `AppCard` per expense:

```
$amount                    Apr 3
Paid by · Alex
Family · Smith Family
{note if present}
```

**Rationale:** User-confirmed layout; mobile-friendly; aligns with existing card-based lists.

**Alternative:** Spreadsheet table with column headers — rejected per product preference.

### 4) Repository: category-filtered range query + creator join

**Decision:** Add `watchCategoryExpensesInMonthWithCreator({ categoryId, startUtcMs, endUtcMs })` — same join pattern as `watchExpensesInRangeWithCreator` with `AND category_id = ?`.

**Rationale:** Keeps streams small; avoids client-side filter on all month expenses.

### 5) Trend data: daily totals within month

**Decision:** Add `watchCategoryDailyTotalsInMonth({ categoryId, startUtcMs, endUtcMs })` returning `{ localDay, totalMinor }` for each day with spend; UI pads missing days to `0` for a continuous line.

**Rationale:** Option B from exploration (within-month daily breakdown). Implementation may aggregate in Dart from the category-filtered stream or use grouped SQL—prefer correctness on local timezone over micro-optimization.

### 6) Family label resolution

**Decision:** On detail screen init (and when sync/household list may change), load `fetchHouseholdsForCurrentUser()` into `Map<householdId, displayName>`. For each row:

- Known id → household name (personal or shared).
- `null` `household_id` → `AppStrings.expenseFamilyUnset` (e.g. em dash or "Local").
- Unknown id → `AppStrings.expenseFamilyUnknown`.

**Rationale:** One batch fetch; works offline with last successful fetch; avoids N+1 `fetchHouseholdDisplayName` calls.

**Alternative:** Restore `household_display_cache` table — deferred; can add if offline UX is insufficient.

### 7) Chart library: `fl_chart`

**Decision:** Add `fl_chart` for `LineChart` on Trend tab; style with `AppColors` / theme text styles.

**Rationale:** No chart code in repo today; `fl_chart` is widely used and sufficient for ~31 points.

**Alternative:** `CustomPainter` — more effort, no strong benefit at this scale.

### 8) Month boundaries

**Decision:** Reuse the same local-month → UTC ms conversion as `MonthlyExpensesView` (`DateTime(year, month, 1)` through first day of next month).

**Rationale:** Tab 1 totals must match the Monthly list row the user tapped.

## Risks / Trade-offs

- **[Risk] Family name missing offline** → Mitigation: show fallback string; refresh map when screen gains focus after sync.
- **[Risk] Timezone edge cases on daily buckets** → Mitigation: bucket using `DateTime.fromMillisecondsSinceEpoch(..., isUtc: true).toLocal()` date parts; add repository test spanning month boundary.
- **[Risk] New dependency size** → Mitigation: use only `LineChart`; pin version in `pubspec.yaml`.
- **[Risk] Empty category month** → Mitigation: `ExpensesEmptyState` on Transactions; flat zero line or empty chart state on Trend.

## Migration Plan

1. Ship client-only; no database migration.
2. No server changes.
3. Archive change updates `openspec/specs/expenses-tab/spec.md` and adds `monthly-category-detail/spec.md`.

## Open Questions

- None blocking v1. Future: row tap to edit expense; sticky date section headers; `MemberAvatar` beside paid-by name.
