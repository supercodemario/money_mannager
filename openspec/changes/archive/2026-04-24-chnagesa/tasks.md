## 1. Layout fix

- [x] 1.1 In `lib/features/expenses/view/add_recurring_payment_screen.dart`, ensure the main form body is `SafeArea` → `ListView` without wrapping the list in extra bottom padding equal to `MediaQuery.viewInsetsOf(context).bottom` while `Scaffold` uses default `resizeToAvoidBottomInset`.
- [x] 1.2 Run `dart analyze` on the touched file(s) and fix any issues introduced by the change.

## 2. Verification

- [x] 2.1 On a physical device (iOS and/or Android), open add recurring and edit recurring flows, focus amount and title, and confirm there is no tall blank band above the keyboard and all controls remain reachable by scrolling.
- [x] 2.2 After implementation is complete, archive this change per project OpenSpec workflow so `openspec/specs/recurring-payments/spec.md` receives the new requirement from the delta.
