## Why

Household and multi-member budgeting makes it important to see **who recorded each expense** at a glance. The daily list today shows category, note, amount, and time only, so attribution is invisible even though every expense already stores `created_by_user_id`. Showing a **compact member identity** (name + stable generated avatar) improves scanability without introducing photo uploads or new database columns.

## What Changes

- **Daily** expense list rows show the **member who created the expense** (treated as “paid by” for this release), using **display name** plus a **small deterministic avatar** derived from **`userId`** via the [`avatar_plus`](https://pub.dev/packages/avatar_plus) package (Multiavatar-style SVG).
- Introduce a **reusable avatar widget** in `lib/share/` (token-sized, no raw hex in views) so Expenses and future screens stay consistent and features do not cross-import.
- **No** new `avatar_url` / image column on `user_profiles` or `expenses` for this change.
- **Out of scope**: separate “paid by” field distinct from creator; monthly/recurring row attribution (unless trivially shared widget only); performance hardening beyond reasonable list sizes (follow-up if needed).

## Capabilities

### New Capabilities

- (none — behavior is scoped to the existing Expenses tab contract.)

### Modified Capabilities

- `expenses-tab`: extend requirements so **Daily** mode transaction rows surface **creator attribution** with **display name** and a **userId-seeded** generated avatar, aligned with existing local persistence (`created_by_user_id`).

## Impact

- **UI**: `DailyExpensesView` / `ExpenseTransactionRow` (or equivalent list row), possibly dashboard “recent expense” rows if they reuse the same row widget.
- **Data**: resolve `UserProfiles.displayName` (and `id` for avatar seed) for `Expense.createdByUserId` through the repository or a thin view-model; no schema migration.
- **Dependencies**: add `avatar_plus` to `pubspec.yaml`.
- **Specs**: delta under this change for `expenses-tab`; after archive, merge into `openspec/specs/expenses-tab/spec.md`.
