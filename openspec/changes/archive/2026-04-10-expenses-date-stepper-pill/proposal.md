## Why

Daily expenses were loaded as a long rolling window and could not be inspected **per calendar day** in the same way Quick Add picks a date. Monthly navigation also used a different visual pattern than the Quick Add date pill, so the Expenses tab felt inconsistent with the rest of the app.

## What Changes

- Reuse and extend **`DateStepperPill`** in `lib/share/widgets/` (stepper layout: **AppCard**, chevrons, leading icon, label) for **Daily** (one day at a time) and **Monthly** (month navigation) on the Expenses tab.
- Add **day-level state** on the Expenses screen: prev/next adjusts the **selected local calendar day**; Daily list loads expenses only for that day range.
- **Lift** month navigation for **Monthly** and **Recurring** modes to the same screen chrome as Daily (no separate plain `Row` header inside the monthly or recurring list).
- Centralize **day/month label formatters** next to the pill widget for reuse.
- Add **string** tooltips for previous/next day on the pill (Quick Add included).

## Capabilities

### New Capabilities

- *(none)* — Presentation and daily filtering extend the existing `expenses-tab` capability.

### Modified Capabilities

- `expenses-tab`: Daily mode behavior changes from a multi-day rolling list to a **single selected day** with stepper; **monthly** navigation is specified to use the **same pill** pattern as the shared Quick Add stepper.

## Impact

- `lib/share/widgets/date_stepper_pill.dart` — `DateStepperPill`, formatters, `expandWidth`, `leadingIcon`, tooltips (shared; not under a single feature).
- `lib/features/add_expense/view/quick_add_screen.dart` — uses shared formatters and tooltips.
- `lib/features/expenses/view/expenses_screen.dart` — `selectedDay`, pills for daily/monthly.
- `lib/features/expenses/widgets/daily_expenses_view.dart` — `selectedDay`, single-day query.
- `lib/features/expenses/widgets/monthly_expenses_view.dart` — list body only (month chrome in parent).
- `lib/share/tokens/app_strings.dart` — day navigation tooltip strings.