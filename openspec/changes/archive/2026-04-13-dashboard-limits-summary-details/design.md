## Context

The dashboard home screen currently shows budget hero, monthly spending card, and upcoming bills, but does not provide a consolidated limits summary with the specific details users asked for: monthly total expense, remaining monthly amount, current savings set, and current daily limit. Relevant data already exists locally in repositories and dashboard flows (`ExpenseLimitsRepository` derived streams and monthly expense totals), so this is primarily a composition and presentation integration.

## Goals / Non-Goals

**Goals:**
- Surface four limits-related details directly on dashboard home:
  - monthly total expense,
  - remaining monthly amount,
  - current savings set,
  - current daily limit.
- Reuse existing local persistence and derived guidance streams rather than introducing new storage or APIs.
- Ensure clear fallback states when limits or savings are not configured.

**Non-Goals:**
- No changes to limits settings screen behavior.
- No database schema or repository contract changes.
- No changes to expense recording logic or guidance formulas.

## Decisions

1. **Add a dedicated dashboard summary widget for limits details**
   - Rationale: Keeps `dashboard_home_screen.dart` simple and isolates formatting/state handling in a focused widget.
   - Alternative: Inflate `DashboardMonthlySpendingCard` with all fields; rejected due to mixed responsibilities and harder iteration.

2. **Compose data from existing sources**
   - Monthly total expense comes from the existing monthly expense total feed used in dashboard.
   - Remaining monthly amount is computed as `max(0, spendablePool - monthlyTotalExpense)`.
   - Current savings set and daily limit come from limits preferences/derived streams.
   - Alternative: Persist an explicit “remaining” value; rejected because it can become stale and duplicates derivable state.

3. **Use explicit unset placeholders**
   - Rationale: Prevents misleading zeros when values are not configured.
   - Alternative: Hide rows when unset; rejected because users asked to always show details.

## Risks / Trade-offs

- **[Risk] Multiple streams can cause flicker or inconsistent snapshots** → **Mitigation:** co-locate stream composition inside one widget and use stable placeholders until all needed values resolve.
- **[Risk] Remaining amount semantics can confuse users (guidance vs hard budget)** → **Mitigation:** label as guidance/remaining from spendable guidance, not enforcement.
- **[Trade-off] Extra dashboard density** → **Mitigation:** keep compact row layout with concise labels and values.
