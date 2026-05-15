## 1. Dependency and shared UI

- [x] 1.1 Add `avatar_plus` to `pubspec.yaml` with a pinned compatible version; run `flutter pub get`
- [x] 1.2 Add a reusable widget under `lib/share/` (e.g. `MemberAvatar` / `UserIdAvatar`) that renders `AvatarPlus` from **`userId`** at token-based `width`/`height`, suitable for list rows
- [x] 1.3 Export the widget from `lib/share/share.dart` if that is the project pattern for shared widgets

## 2. Data layer

- [x] 2.1 Extend or add a repository/stream API so Daily expenses can be observed **with** creator `displayName` (and `id`) resolved from `createdByUserId` without N+1 queries (e.g. join or combined stream returning a small DTO)
- [x] 2.2 Handle edge case where profile row is missing: safe fallback label and avatar placeholder consistent with app style

## 3. Expenses Daily UI

- [x] 3.1 Thread creator fields into `DailyExpensesView` / `ExpenseTransactionRow` (or equivalent) without violating feature import boundaries (`features/` → `share` / `data` only)
- [x] 3.2 Implement row layout per design: secondary line with small avatar + **display name** (and optional `AppStrings` prefix once copy is chosen)
- [x] 3.3 Add or reuse `AppStrings` key for the attribution label (align with design: “Recorded by” vs “Paid by” vs name-only)

## 4. Verification

- [x] 4.1 Update or add widget/repository tests covering row presence of creator name and that avatar widget receives **`userId`** as seed
- [x] 4.2 Run `flutter analyze` on touched packages; fix any new issues
