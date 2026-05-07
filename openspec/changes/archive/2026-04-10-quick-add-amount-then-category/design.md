## Context

`QuickAddScreen` today uses a single `ListView` with date, amount display, note, always-visible category pager, custom keypad, and a “Select category” button that scrolls to the category block. The product direction is **amount-first**: reduce noise until the user has entered a positive amount, then show categories. Styling remains **token-first** per project rules.

## Goals / Non-Goals

**Goals:**

- Two explicit **modes**: **amount entry** and **category selection**, driven by local `State` (enum or booleans).
- **Gate** category mode until parsed amount **> 0** (`0.00` invalid).
- **Clear** `selectedCategoryId` whenever transitioning **back** to amount entry mode (including tapping the amount region to edit).
- **Date + note** remain visible in **both** modes (user confirmed).
- Show **“Tap category to save instantly”** (or current equivalent string) **only** in category mode.
- Prefer replacing root `ListView` with `**Column` + `Expanded`** so the middle region flexes; allow **inner** scroll on category pager only if needed on very small height.

**Non-Goals:**

- Persisting expenses to storage or API (save/check still stubbed unless already separate).
- Changing bottom navigation or FAB entry points.
- Sticky read-only amount banner in category mode (**optional** — not required for this change).

## Decisions

1. **State model**
  - **Choice:** `enum QuickAddMode { amount, category }` (or two bools with invariant).  
  - **Rationale:** Clear transitions; easy to test visibility.
2. **Amount > 0**
  - **Choice:** Derive a `double` or minor-units `int` from `_amountInt`, `_amountFrac`, `_hasDot` (treat incomplete decimals consistently, e.g. `12.` → 12.00 for gating).  
  - **Rationale:** Matches display model without parallel string parsing.
3. **Select category control**
  - **Choice:** `FilledButton` (or `FilledButton.tonal`) **disabled** when amount ≤ 0; no separate snackbar unless UX testing asks for it.  
  - **Rationale:** Meets validation without extra noise.
4. **Return to amount mode**
  - **Choice:** Wrap amount `Text` row in `InkWell` / `GestureDetector` with semantics label “Edit amount”; on tap → `mode = amount`, `_selectedCategoryId = null`.  
  - **Rationale:** Discoverable; clears category per spec.
5. **Layout**
  - **Choice:** `Scaffold` → `SafeArea` → `Column` with `Expanded(child: …)` for the variable middle (category grid **or** spacer above keypad).  
  - **Rationale:** Avoids whole-page scroll; keypad can sit in a fixed bottom region.
6. **Category mode exit**
  - **Choice:** Provide **explicit** way back to amount mode: reuse **leading close** on app bar only pops route; prefer **icon/button** near amount (“Edit”) or a **secondary** “Edit amount” text button under the summary.  
  - **Rationale:** User must not be trapped in category mode without system back.

## Risks / Trade-offs

- **Small screens** — Column + fixed keypad may clip category grid → **Mitigation:** `Expanded` + `SingleChildScrollView` only around category section in category mode.  
- **Double source of truth** — Amount display vs gate logic drift → **Mitigation:** single `_amountValue` helper used by display and gating.  
- **Accessibility** — Mode changes need **Semantics** / focus → **Mitigation:** announce mode or ensure focus order reasonable.

## Migration Plan

Not applicable (UI-only). Rollback: revert `QuickAddScreen` and widget tweaks.

## Open Questions

- Whether category mode needs a visible **“Edit amount”** label in addition to tapping the amount row (copy from `AppStrings` if added).

