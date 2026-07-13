## Context

Home’s monthly spending card shows remaining/overspent and a single indicative-daily pill (currently derived as remaining ÷ daysInMonth in code, with an unarchived `indicative-daily-from-remaining` change). Users need both a **fixed plan** (`pool ÷ D`) and a **pace** figure (`remaining ÷ days after today`), nested under Monthly remaining, plus a tappable month day listing (plan vs spent, red/green).

## Goals / Non-Goals

**Goals:**

- Expose **Daily plan** and **Pace / day** on Home under the monthly remaining block.
- Open a month day listing from that dual-daily row.
- Compare each day to Daily plan for over/under coloring.
- Keep guidance non-blocking; reuse existing pool / remaining / expense month streams.

**Non-Goals:**

- Changing spendable pool formula or unpaid-recurring rules.
- Masking these amounts under privacy mode (unless already decided elsewhere).
- Pace that includes today in the divisor.
- Historical “pace as of that day” on the listing (listing uses fixed Daily plan only).
- Redesigning Expense Limits Stitch layout beyond aligning the daily label to Daily plan if shown.

## Decisions

### 1. Dual formulas

**Choice:**

- `dailyPlanMinor = pool > 0 ? pool ~/ D : 0`
- `remainingMinor = pool − monthSpent` (unchanged; may be negative)
- `daysAfterToday = D − dayOfMonth` (local calendar; **exclude today**)
- `paceDailyMinor = (remaining > 0 && daysAfterToday > 0) ? remaining ~/ daysAfterToday : 0`

**Why:** Matches product example (30 pool / 30 days → plan 1; after remaining 19 on day 10 → pace `19 ~/ 20 = 0`).

**Alternatives:** Include today in divisor (rejected by product); pace = remaining ÷ D (current single metric — rejected).

### 2. Home UI: nest under Monthly remaining

**Choice:** Extend `DashboardMonthlyBalanceRow` (or replace with a richer block) to show remaining/overspent amount plus a second row: **Daily plan | Pace / day**. Remove the standalone indicative-daily pill beside savings; keep savings pill alone or full-width as fits existing layout.

**Why:** Product asked to merge with monthly remaining; savings stays separate.

**Tap target:** The dual-daily row (or the whole remaining card section’s daily strip) navigates to the listing screen.

### 3. Calculator / derived model

**Choice:** Add `dailyPlanMinor` and `paceDailyMinor` on `ExpenseLimitsDerived` (or equivalent). Prefer renaming away from a single `indicativeDailyMinor` for Home; Expense Limits detail can show Daily plan as its daily summary. Centralize math in `ExpenseLimitsCalculator`.

**Why:** One source of truth; tests cover the day-10 example.

### 4. Month day listing

**Choice:** New routed screen for the **current local month**. For each day `1…D`:

- `plan = dailyPlanMinor`
- `spent = sum(expenses that local day)` (0 if none)
- Color: spent > plan → error/red; spent ≤ plan → secondary/green (equal counts as under/OK green)
- Future days: show plan and spent `0` or `—`; if spent is 0 and day is future, prefer neutral styling (not green “success”) — **Decision:** future days with zero spent use muted/neutral; only days `≤ today` apply red/green.

**Why:** Avoid painting the whole future month green. Past/today use the rule; future is informational.

### 5. Data for listing

**Choice:** `watchExpensesInRange` for month UTC window already used on Home; group by local `yyyy-MM-dd`. No new persistence.

### 6. Last day of month

**Choice:** `daysAfterToday == 0` → pace `0` (or display as unset/zero consistently).

## Risks / Trade-offs

- **[Risk] Unarchived `indicative-daily-from-remaining`** still defines remaining÷D as “indicative daily.” → This change supersedes that Home meaning; archive/sync order should apply this delta as the new source of truth for dual metrics.
- **[Risk] Integer division** on small currencies yields 0 pace early. → Accept floor; same as existing guidance style.
- **[Risk] Timezone / UTC range vs local day grouping** → Reuse Home’s month range helpers; group by local date consistently with Expenses tab.
- **[Trade-off] Future days neutral** vs always green at 0 → Neutral avoids false “good” signals.

## Migration Plan

1. Calculator + derived fields + unit tests (include 30/30 and day-10 remaining 19 → pace 0).
2. Home remaining block UI + navigation.
3. Listing screen + route + day aggregation.
4. Align Limits detail daily label to Daily plan if it still shows one daily.
5. Rollback: restore single daily pill; remove route (no DB migration).

## Open Questions

- None blocking (labels and exclude-today confirmed).
