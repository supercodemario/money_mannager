## Context

The dashboard monthly spending card already combines monthly spent totals and derived expense-limit guidance (`spendablePoolMinor`, `indicativeDailyMinor`). Current UI clamps progress and remaining values, which hides when spending exceeds guidance. Users requested an explicit exceed indication with warning color and quantified overage.

## Goals / Non-Goals

**Goals:**
- Detect over-budget state from existing spent and spendable values.
- Present exceed state with clear red styling and text (status, progress, amount).
- Show exceeded amount and exceeded percentage in addition to used percentage.
- Preserve existing behavior for unset limits and non-exceed states.

**Non-Goals:**
- No changes to expense-limit calculation formulas.
- No blocking or validation that prevents expense creation.
- No database schema or repository API changes.

## Decisions

1. **Derive over-budget from existing card inputs**
   - `overBudget = hasLimits && monthlySpent > spendablePool`.
   - Why: avoids new storage/streams and keeps source-of-truth in current derived values.
   - Alternative: Persist "over-budget" flag; rejected as redundant and stale-prone.

2. **Expose both usage and overage percentages**
   - Keep "used %" (`spent / spendable`) and add "exceeded %" (`(spent - spendable) / spendable`) when over budget.
   - Why: users need both total usage context and explicit overage magnitude.
   - Alternative: show only used % (e.g., 124%); rejected because exceeded delta is less obvious.

3. **Use warning semantics only in over-budget state**
   - Apply red accents to monthly amount, progress text/fill, and overage text; keep normal green semantics otherwise.
   - Why: preserves positive/negative visual contrast without overwhelming normal state.
   - Alternative: always show red for remaining card only; rejected due to fragmented signal.

4. **Switch remaining section label in exceed state**
   - Replace "MONTHLY REMAINING" with "MONTHLY OVERSPENT" and display absolute overage amount.
   - Why: avoids confusing negative currency presentation and improves readability.

## Risks / Trade-offs

- **[Risk] Visual overload from too many red elements** → **Mitigation:** confine red to exceed-specific fields and keep body text neutral.
- **[Risk] Percent confusion when spendable pool is zero/unset** → **Mitigation:** guard percent and exceed calculations behind `hasLimits && spendablePool > 0`.
- **[Trade-off] Absolute overage hides signed arithmetic** → **Mitigation:** include explicit "+" wording in exceeded label and subtitle.
