## Why

Users on the home dashboard need a fast, obvious way to start adding an expense without hunting for the bottom “Add” tab. A floating action on the home screen matches common finance-app patterns and complements the Stitch “Quick Add (Maximized Controls)” direction: jump straight into the add-expense flow from the primary overview.

## What Changes

- Add a **floating action button (FAB)** on the **home** screen (`DashboardHomeScreen`) that starts the same add-expense experience as the shell’s central Add tab (navigate to / show `AddExpenseScreen`).
- Style the FAB with **shared design tokens** (no raw hex in feature code); visual language should align with the existing app chrome and the Stitch reference assets in this change.
- Store **Stitch reference assets** (screenshot + HTML) under `stitch-reference/` for implementation and future UI alignment (e.g. maximized keypad layout).

## Capabilities

### New Capabilities

- `home-quick-add-fab`: Home dashboard shows a quick-add FAB; tapping it opens the add-expense flow consistently with bottom navigation.

### Modified Capabilities

- _(none)_ — Shell wiring is an implementation detail (callback from shell into dashboard). No change to published bottom-navigation or add-expense *requirements* unless we later split “quick add” UI into a separate spec.

## Impact

- `lib/features/dashboard/` — `DashboardHomeScreen` (and possibly a small widget under `widgets/`).
- `lib/features/shell/view/app_shell.dart` — pass navigation callback so the FAB can switch to the Add tab / expense screen.
- Reference only: `openspec/changes/home-quick-add-fab/stitch-reference/` (PNG + HTML from Stitch project `12107255462624662036`, screen `d013b1018fc846abacd7707912458931`).
