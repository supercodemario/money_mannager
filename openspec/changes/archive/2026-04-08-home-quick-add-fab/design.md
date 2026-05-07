## Context

The app shell uses an `IndexedStack` with Home → Expenses → Add → Insights → Settings. `DashboardHomeScreen` is the first tab; add expense is already available via the central Add tab (`AddExpenseScreen`). The Stitch screen **Quick Add (Maximized Controls)** (project `12107255462624662036`, screen `d013b1018fc846abacd7707912458931`) is a full-screen add flow with large amount, swipeable category pages, and an oversized keypad—HTML and PNG are vendored under `stitch-reference/` for visual alignment in later iterations. This change only adds the **home FAB entry point**; it does not rebuild the entire screen to match Stitch in one step.

## Goals / Non-Goals

**Goals:**

- Show a **FAB** on the home dashboard that is visible above scroll content and uses **design tokens** (`AppColors`, `AppSpacing`, `AppRadius`, etc.).
- On tap, navigate the user to the **same add-expense experience** as choosing the bottom **Add** tab (switch shell index to Add / show `AddExpenseScreen`).
- Keep shell state handling explicit: **parent** (`AppShell`) owns tab index; **child** (`DashboardHomeScreen`) receives a callback.

**Non-Goals:**

- Reimplement the Stitch maximized keypad, horizontal category pager, or “tap category to save instantly” in this change (future work; reference assets remain for design parity).
- Change bottom navigation requirements or add-expense functional requirements beyond entry path.

## Decisions

1. **Callback from `AppShell` → `DashboardHomeScreen`**  
   - **Choice:** `AppShell` passes `VoidCallback onOpenAddExpense` (or `ValueChanged<int>` if we prefer index `2` explicitly).  
   - **Rationale:** Avoids global keys, `findAncestorStateOfType`, or route duplication; tab index stays in one place.  
   - **Alternative:** Navigator push of `AddExpenseScreen` — would duplicate the shell’s Add slot and break consistency with bottom nav highlighting.

2. **FAB placement**  
   - **Choice:** `Scaffold` with `floatingActionButton` and `floatingActionButtonLocation: endFloat` (or `miniFab` if density is an issue).  
   - **Rationale:** Standard Material pattern; sits above list content but below the glass bottom bar visually when user scrolls; matches “floating button” ask.

3. **Icon / semantics**  
   - **Choice:** `Icons.add` (or `add_rounded`) with `AppStrings` for semantic label if needed (`tooltip` / `semanticLabel`).  
   - **Rationale:** Matches “quick add” affordance; optional string `addExpenseFabTooltip` in `AppStrings` if we add tooltip.

4. **Stitch assets**  
   - **Choice:** Keep `stitch-reference/quick-add-maximized-controls.png` and `.html` as **non-runtime** references; do not bundle them in `assets/` for the Flutter app.  
   - **Rationale:** Satisfies “curl download” for the change; implementation uses tokens, not HTML/CSS.

## Risks / Trade-offs

- **FAB overlaps bottom nav** — On small screens the FAB may sit near the glass bar → **Mitigation:** use `padding` or `MediaQuery` + `kBottomNavigationBarHeight` if needed; Flutter `endFloat` usually clears the bar area when combined with `Scaffold` padding.  
- **Duplicate entry points** (FAB + Add tab) — **Mitigation:** acceptable; both land on same screen.  
- **Stitch parity** — **Mitigation:** document in follow-up change that `AddExpenseScreen` layout can converge toward `stitch-reference/` HTML.

## Migration Plan

Not applicable (no data migration). Rollback: remove FAB and callback parameter.

## Open Questions

- Whether to add a **widget test** that FAB triggers the same callback as switching to Add tab (optional; can be task 3.x).
