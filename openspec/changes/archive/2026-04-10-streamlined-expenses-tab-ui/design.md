## Context

The Expenses tab implements three modes (Daily, Monthly, Recurring) with distinct list content. The Stitch “Streamlined Expenses” reference uses a **pill track** with **inner padding** and a **sliding rounded indicator** behind labels, which is not how Material `SegmentedButton` composes selected state. The implementation therefore uses a small custom layout (stacked indicator + tap targets) scoped to the Expenses screen unless reuse is needed elsewhere.

## Goals / Non-Goals

**Goals:**

- Match the reference pattern: muted track, sliding green pill, white (or equivalent high-contrast) label on the selected segment, subdued labels on unselected segments.
- Animate indicator movement between modes (~300ms, ease-in-out) for clarity.
- Show a **check icon** next to **Daily** when Daily is selected, per reference.
- Keep behavior of switching modes and FAB rules for recurring add unchanged.

**Non-Goals:**

- Redesign Daily, Monthly, or Recurring list rows in this change.
- Change bottom navigation or global theme.
- Persist mode selection beyond existing in-memory state (unless already present).

## Decisions

1. **Custom switcher instead of `SegmentedButton`**

   - **Rationale:** Stitch uses a single sliding underlay; `SegmentedButton` paints selection per segment and does not replicate the “floating pill” affordance without heavy overrides.
   - **Alternative considered:** Themed `SegmentedButton` only — rejected after visual comparison with the reference.

2. **Layout: `Stack` + `AnimatedPositioned` + `Row` of three equal tap targets**

   - **Rationale:** Predictable thirds alignment and straightforward animation of `left` offset.
   - **Alternative considered:** `TabBar` with custom indicator — more coupling to tab scaffold semantics than needed.

3. **Colors from shared tokens**

   - Use `AppColors.secondary` for the pill and existing surface/on-surface tokens for track and text. Reserve raw palette literals only for the slate track tint if no token match exists, documented in code.
   - **Alternative considered:** Hard-match Tailwind hex for every pixel — rejected to stay consistent with app theme.

4. **Widget placement**

   - Implement as private widgets in `expenses_screen.dart` until a second screen needs the same control; then extract to `share/widgets` or `features/expenses/widgets`.

## Risks / Trade-offs

- **[Risk] Exact hex match to Stitch vs app green** → **Mitigation:** Document that brand secondary green is canonical; adjust only if design system mandates a separate “emerald” token later.
- **[Risk] RTL layout** → **Mitigation:** If RTL is enabled later, replace fixed `left` animation with directional alignment or `Directionality`-aware offsets.
- **[Risk] Tap target size** → **Mitigation:** Keep segments `Expanded` so each third is a full hit target.

## Migration Plan

- Ship as a standard app update; no data migration.
- Rollback: revert `expenses_screen.dart` to prior switcher widget.

## Open Questions

- Whether to extract a reusable `PillModeSwitcher<T>` after a second use case appears.
