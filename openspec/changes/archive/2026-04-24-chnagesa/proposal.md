## Why

On physical devices, the add/edit recurring payment template screen showed a large blank (often white) band above the soft keyboard when focusing the title or amount fields. That broke visual continuity and made the form feel broken compared to simulator use. The root cause is applying the keyboard inset twice: `Scaffold` already shrinks the body by default (`resizeToAvoidBottomInset`), and the screen also padded by `MediaQuery.viewInsets.bottom`.

## What Changes

- Remove redundant bottom padding driven by `MediaQuery.viewInsets` on the add/edit recurring template screen body so the keyboard inset is applied only once.
- Keep the form in a scrollable (`ListView`) body under `SafeArea` so fields remain reachable when the IME is open.
- Encode the expected UX in the **recurring-payments** capability spec so future edits do not reintroduce double-inset patterns.

## Capabilities

### New Capabilities

- _(none)_

### Modified Capabilities

- `recurring-payments`: Add a requirement that the add/edit recurring template form MUST lay out correctly with the on-screen keyboard (no duplicate inset / no large dead band hiding content).

## Impact

- **Code**: `lib/features/expenses/view/add_recurring_payment_screen.dart` (layout only; no data or routing changes).
- **Other screens**: None; this pattern was unique to this file.
- **Dependencies**: None.
