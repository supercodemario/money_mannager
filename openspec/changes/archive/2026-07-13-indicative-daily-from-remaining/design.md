## Context

Indicative daily is `spendablePool ~/ daysInMonth`. Spendable pool subtracts unpaid recurring only when exclude-unpaid-recurring is on. Marking a recurring paid removes it from **R** and records an expense, so the pool rises while money is already gone — daily overstates free-to-spend. Dashboard already computes `remaining = pool - monthlySpent` for the remaining/overspent row but still shows pool-based daily.

## Goals / Non-Goals

**Goals:**
- Make indicative daily track **remaining** guidance so paid bills (and any other month spend) reduce daily.
- Keep a single coherent definition of remaining for dashboard + limits UI.
- Preserve pool formula and non-blocking guidance.

**Non-Goals:**
- Changing remaining ÷ **days left** (pace-to-month-end); divisor stays **calendar days in month**.
- Changing unpaid-recurring reservation rules for the pool itself.
- Enforcing hard spend caps.
- Redesigning Expense Limits Stitch layout.

## Decisions

### 1. Indicative daily = floor(max(0, remaining) / D)

**Choice:**  
`remaining = spendablePool − monthlySpent` (same as dashboard).  
`indicativeDaily = remaining > 0 ? remaining ~/ daysInMonth : 0`.

**Why:** After paying rent+gas, spent includes those amounts, remaining stays reduced, daily stays reduced — matches “paid money is lost from salary.” When bills are still unpaid and exclude is on, pool already reserves them and spent does not yet include them — daily stays conservative without double-counting.

**Alternatives considered:**
- Deduct all recurring (paid+unpaid) from pool forever — double-counts once expenses exist unless spent filters recurring; more complex.
- `remaining / daysLeft` — better mid-month pacing but larger behavior change; deferred.
- Keep pool-based daily — rejected (user shortage case).

### 2. Centralize derivation (not only UI)

**Choice:** Extend the derived-limits path so indicative daily is computed with current-month spent (repository/calculator), and dashboard/limits screens consume that value. Avoid duplicating formulas in widgets.

**Why:** Limits detail and dashboard must stay consistent; tests can cover calculator/repository.

### 3. Overspent → daily zero

**Choice:** If remaining ≤ 0, indicative daily is 0 (not a negative daily).

**Why:** Guidance means “nothing left at a sustainable average”; overspent is already shown on the remaining/overspent row.

### 4. Month spent scope

**Choice:** Use the same month total expense already used by the dashboard monthly spending card (active household/user scope for the current local month).

**Why:** Remaining and daily must share one spent definition.

## Risks / Trade-offs

- [Daily shrinks as any expense is added, not only recurrings] → Mitigation: intentional; remaining-based daily is the coherent salary model.
- [Unpaid exclude off + unpaid bills] → Mitigation: unchanged; those bills are not reserved until paid/spent — document in specs.
- [Repository stream must also watch expenses] → Mitigation: combine existing expense month stream with prefs/recurring watches; keep month rollover behavior.

## Migration Plan

1. Update calculator + derived model/tests.
2. Wire month spent into `watchDerived` (or equivalent).
3. Confirm dashboard and limits screens show the new daily without separate pool-based math.
4. Rollback: revert formula to `pool ~/ D` if needed (no data migration).

## Open Questions

- None blocking; days-left divisor deferred unless product asks later.
