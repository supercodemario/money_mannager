## Context

The app persists expenses and recurring templates in **Drift**; recurring rows carry `isEnabled`, occurrences per `monthKey`, and unpaid state when `expenseId` is null. Settings already has a **Limits** card with static badge/progress and no navigation. Home dashboard widgets still use **hardcoded** example amounts for daily/monthly presentation.

## Goals / Non-Goals

**Goals:**

- Persist user inputs: **monthly income** (minor units, same currency convention as expenses, e.g. USD minor), optional **monthly savings reservation** (minor units), optional boolean **subtract unpaid enabled recurring** for the **current local calendar month**.
- Deterministically compute: **spendable pool** = income − savings − (if enabled) sum of `amount_minor_suggested` for templates that are **scheduling-enabled** and **unpaid** for that month’s `monthKey`.
- Compute **indicative daily** = floor(pool ÷ daysInMonth) or documented rounding; **indicative monthly** aligns with pool (same as spendable remainder for the month).
- Provide a **limits detail screen** from Settings; show copy that values are **guidance**, not blocks on spending.

**Non-Goals:**

- Manual-only limits (no income) in v1.
- Blocking or warning dialogs when user exceeds daily guidance.
- Server sync, multi-currency income beyond app’s current expense currency assumptions.
- Debit/credit variance UI on home (explicitly later).

## Decisions

1. **Storage shape**  
   **Decision:** Single-row table `expense_limit_preferences` (or named equivalent) keyed by `user_profile_id` matching current app’s profile FK pattern, with columns: `monthly_income_minor` (nullable), `monthly_savings_minor` (nullable or 0), `exclude_unpaid_recurring` (bool, default false), `updated_at`.  
   **Rationale:** Clear migration path; avoids overloading `UserProfiles` with finance fields.  
   **Alternative:** JSON blob on profile — rejected for query clarity and validation.

2. **Which month for recurring unpaid sum**  
   **Decision:** **Current local calendar month** (`monthKey` from `DateTime.now()` local), consistent with “how much is still committed this month.”  
   **Rationale:** Matches user expectation when setting limits “for this month.”  
   **Alternative:** User-selectable month on limits screen — deferred.

3. **Rounding**  
   **Decision:** Use **integer division (floor)** for daily = `poolMinor ~/ daysInMonth` when `daysInMonth > 0`; if `poolMinor <= 0`, daily shows **0**.  
   **Rationale:** Predictable, avoids overstating.  
   **Alternative:** Round nearest — document if product prefers.

4. **Repository boundary**  
   **Decision:** Add a method on `RecurringPaymentRepository` or a small `ExpenseLimitsRepository` that composes profile prefs + recurring sum + pure **Dart** calculator (unit-test friendly).  
   **Rationale:** Keeps formula in one place.

5. **Dashboard**  
   **Decision (v1):** Implement persistence + Settings screen first; **optional task** to bind `dashboard_monthly_spending_card` (or equivalent) to derived daily string when prefs exist.  
   **Rationale:** Delivers value without blocking on full home redesign.

## Risks / Trade-offs

- **[Risk]** Income changes mid-month → **[Mitigation]** Recalc immediately on save; document in UI as “for this month.”  
- **[Risk]** User enables “exclude recurring” but has no unpaid items → **[Mitigation]** Sum is 0; pool unchanged except savings.  
- **[Risk]** Disabled recurring excluded from sum by definition (only **enabled** templates considered).  
- **[Trade-off]** “Suggested” recurring amount may differ from actual paid amount — copy in UI: uses **scheduled** amounts for unpaid lines.

## Migration Plan

- Schema version bump; `CREATE TABLE` for limit preferences; optional seed row none (null income until user sets).

## Open Questions

- Whether **empty income** should hide guidance everywhere or show zeros — recommend **hide or “Not set”** on dashboard until income saved.
