## Context

`openspec/specs/PROJECT_STRUCTURE_SPEC.md` currently says `widgets/` is **optional** and describes it as a place for “reusable UI pieces.” In practice, several screens were implemented with **private** `StatelessWidget` / `StatefulWidget` classes in the same file as the screen (`view/`), e.g. `_BudgetHero`, `_DailyExpensesView`. That is valid Dart and was faster during feature delivery, but it conflicts with your **stricter team convention**: child widgets belong under `feature/widgets/`.

## Goals / Non-Goals

**Goals:**

- Align **dashboard** and **expenses** features with the convention.
- Update **PROJECT_STRUCTURE_SPEC.md** so the rule is unambiguous (not “optional” for non-trivial child widgets).
- Keep **public APIs** of screens stable (`DashboardHomeScreen`, `ExpensesScreen` constructors unchanged unless necessary).

**Non-Goals:**

- Moving **add_expense** or **shell** widgets in this change (can follow the same pattern later).
- Introducing **cross-feature** widgets (those stay in `lib/share/widgets/`).
- Adding **custom_lint** or CI enforcement in v1 (optional follow-up).

## Decisions

1. **Rule wording**  
   - **Decision:** Any `Widget` subclass that is **not** the primary screen widget for that file **shall** live under `lib/features/<feature>/widgets/`, named as **public** widgets (no leading `_` in file-private types—use package-private via library or `part` only if needed; prefer public names like `DashboardBudgetHero`).  
   - **Rationale:** Matches your convention; `view/` stays “composition root” only.

2. **Exception: tiny local builders**  
   - **Decision:** Allow **very small** private helpers only when they are a few lines and not reused (e.g. a single `Padding` wrapper). If it has its own `build` method and substantive tree, it moves to `widgets/`.  
   - **Rationale:** Avoid file explosion for trivial noise.

3. **Exports**  
   - **Decision:** Import widgets from `widgets/*.dart` into the screen; no barrel file required unless the feature already uses one.

4. **PROJECT_STRUCTURE_SPEC update**  
   - **Decision:** Replace “Optional: add `widgets/` …” with normative language: create `widgets/` for feature-scoped building blocks; **do not** define separate widget classes in `view/` screen files except the screen itself (and trivial exceptions above).

## Risks / Trade-offs

| Risk | Mitigation |
|------|------------|
| Large diff / merge conflicts | Touch only dashboard + expenses in this change |
| Over-splitting one-line widgets | Apply the “substantive `build`” threshold |

## Migration Plan

1. Add `widgets/` files; move classes; update imports.
2. Run `flutter analyze` / `flutter test`.
3. Edit `PROJECT_STRUCTURE_SPEC.md` to match.

## Open Questions

- Whether to use **barrel** `widgets.dart` exports per feature (nice for imports; not required).
