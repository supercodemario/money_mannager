## Context

The app already supports expense limits persistence and derived guidance calculations, but the current `ExpenseLimitsScreen` does not align with the approved Stitch v3 composition. The user requested a new screen pass driven by Stitch project `12107255462624662036`, screen `8cc417ddb6a94343a7793468ef9ccc8a`, including use of hosted screenshot and HTML references retrieved via `curl -L`.

The implementation must preserve existing data behavior (income/savings/exclude-recurring persistence and derived guidance semantics) while delivering the new visual hierarchy and savings percentage-goal interaction pattern.

## Goals / Non-Goals

**Goals:**

- Align the limits screen UI composition with Stitch v3 sections and visual rhythm.
- Add a savings-goal interaction model that supports percentage-based adjustment while remaining compatible with stored minor-unit savings values.
- Keep existing repository contracts, validation expectations, and non-blocking guidance behavior.
- Capture a repeatable design-reference workflow (download screenshot + HTML) for implementation and QA parity.

**Non-Goals:**

- No database schema changes.
- No new backend APIs or remote sync behavior.
- No changes to core spendable/daily calculation formulas beyond already-approved rules.
- No redesign of unrelated settings/home flows.

## Decisions

1. **Reuse existing `expense-limits` capability and refine the existing screen**
  - Rationale: The request is a visual/interaction refinement of an existing feature, not a separate domain capability.
  - Alternative considered: Introduce a new capability for “limits-v3-ui”. Rejected because behavior remains in the same bounded context.
2. **Drive design parity from downloaded Stitch artifacts**
  - Rationale: Using both screenshot and HTML reduces interpretation drift and provides traceable source inputs.
  - Alternative considered: Recreate from textual memory only. Rejected due to prior alignment mismatches.
3. **Represent savings percentage as UI state mapped to existing savings amount persistence**
  - Rationale: Existing persistence stores savings in minor currency units; introducing a persisted percentage would require schema/contract changes.
  - Alternative considered: Persist an explicit percentage value. Rejected for scope and migration overhead.
4. **Keep existing repository/API boundaries unchanged**
  - Rationale: `ExpenseLimitsRepository` already provides required inputs/derived outputs; UI can be layered without data-layer refactor.
  - Alternative considered: Expand derived DTO for additional UI-only fields. Deferred unless later required.

## Risks / Trade-offs

- **[Risk] Visual parity still differs subtly from Stitch tokens/spacing** → **Mitigation:** use side-by-side review against downloaded screenshot and iterate exact spacing/radius/typography values.
- **[Risk] Savings slider and amount text field can become out of sync** → **Mitigation:** centralize conversion logic between percentage and savings minor amount; update both directions deterministically.
- **[Risk] UI-focused refactor may regress validation/save flow** → **Mitigation:** preserve existing validation rules and run analyzer plus manual save/invalid-input checks.
- **[Trade-off] Maintaining old persistence shape limits how much of Stitch semantics can be modeled directly** → **Mitigation:** treat percentage goal as presentation-layer control mapped to current savings field.