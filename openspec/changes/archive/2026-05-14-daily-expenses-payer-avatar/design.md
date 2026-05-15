## Context

- Each `Expense` row already includes `createdByUserId` referencing `UserProfiles` (`displayName`, `id`). The **Daily** list (`DailyExpensesView` → `ExpenseTransactionRow`) does not surface this.
- Settings uses a generic circular icon, not a per-user generated avatar. Household work in the repo increases the value of **per-member** affordances.
- The team chose **`avatar_plus`** (Multiavatar) with seed **`userId`** for a stable image, **`displayName`** for visible text, and **no** new image column.

## Goals / Non-Goals

**Goals:**

- Show **creator** identity on **Daily** expense rows (label + small avatar).
- Centralize avatar rendering in **`lib/share/`** with design tokens for size and spacing.
- Resolve profile fields through existing repository/database boundaries (no Drift types leaking into generic widgets if avoidable).

**Non-Goals:**

- Distinguishing **payer** from **creator** (separate column or picker).
- **Monthly** / **Recurring** lists, unless the same row widget is reused without extra scope.
- **Uploaded** profile photos, Supabase Storage, or migrations adding `avatar_url`.
- Deep performance work (e.g. raster caching pipeline); optional note in tasks if list jank appears.

## Decisions

1. **`avatar_plus` dependency**  
   - **Rationale**: Deterministic SVG avatars from `userId`; no blob storage.  
   - **Alternative**: Initials-only `CircleAvatar` — fewer deps, less visual noise, no Multiavatar license/style concerns. Rejected for this change per product preference.

2. **Seed = `userId`, label = `displayName`**  
   - **Rationale**: Avatar stable across renames; text stays current.  
   - **Alternative**: Seed `displayName` — rejected (duplicate names → duplicate avatars; rename churn).

3. **Semantic label “Paid by” vs “Added by”**  
   - **Rationale**: Proposal uses **creator** as stand-in for payer for v1. Prefer a string key that does not overclaim if legal/support care: e.g. **“Recorded by”** or neutral **member name** only. **Decision for copy**: use a single `AppStrings` entry; default recommendation **“Recorded by”** unless product insists on “Paid by”.

4. **Data plumbing**  
   - **Option A**: Extend `ExpenseRepository.watchExpensesInRange` to emit a small DTO (e.g. `ExpenseWithCreator`) joining profile in one query.  
   - **Option B**: Watch expenses and profiles separately and merge in a cubit.  
   - **Preference**: **Option A** (or repository-level stream combine) to keep the list widget simple and avoid N+1 profile reads. Exact shape follows existing repository patterns.

5. **Widget placement in row**  
   - Secondary line under note (or under category if no note): **leading** tiny avatar + short label, preserving amount/time column. Keeps tap targets and truncation predictable.

6. **Feature isolation**  
   - Shared avatar widget lives under `lib/share/`; expenses feature imports `share`, not vice versa.

## Risks / Trade-offs

| Risk | Mitigation |
|------|------------|
| SVG cost in long lists | Keep avatar dimension small (token height ~20–24); consider `RepaintBoundary` if profiling shows jank; document follow-up. |
| `avatar_plus` maintenance / SDK drift | Pin conservative version; smoke-test `flutter analyze` / tests after upgrade. |
| “Paid by” copy mismatch | Use accurate string (“Recorded by”) until true payer field exists. |
| Missing profile row for `createdByUserId` | Defensive fallback: show user id substring or “Unknown” + generic icon per existing error-handling style. |

## Migration Plan

- **Deploy**: App update only; `pubspec.yaml` dependency add; no DB migration.
- **Rollback**: Remove dependency and row UI; revert to prior row layout.

## Open Questions

- Whether **dashboard** recent-expense widgets should show the same attribution in the same change (only if trivial reuse).
- Final **copy** string: “Paid by” vs “Recorded by” vs name-only.
