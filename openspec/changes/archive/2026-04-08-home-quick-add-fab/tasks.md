## 1. Stitch reference (change folder)

- [x] 1.1 Confirm `stitch-reference/quick-add-maximized-controls.png` and `quick-add-maximized-controls.html` exist (downloaded from Stitch project `12107255462624662036`, screen `d013b1018fc846abacd7707912458931`)

## 2. Shell wiring

- [x] 2.1 Extend `AppShell` to pass an `onOpenAddExpense` (or equivalent) callback into `DashboardHomeScreen` that sets the tab index to the Add slot (same as tapping the bottom Add tab)

## 3. Home FAB UI

- [x] 3.1 Add a `FloatingActionButton` (or `FloatingActionButton.extended` if design requires) to `DashboardHomeScreen` that calls the callback on press
- [x] 3.2 Apply token-first styling (primary/surface colors, radius, elevation/shadow per existing patterns) and accessibility (tooltip / semantic label if needed)

## 4. Strings

- [x] 4.1 Add any new `AppStrings` entries used by the FAB (e.g. tooltip) if not already covered

## 5. Verification

- [x] 5.1 Run `flutter test` (and add or update a widget test if we assert FAB → callback)
