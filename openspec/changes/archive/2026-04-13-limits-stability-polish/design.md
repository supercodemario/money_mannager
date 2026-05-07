## Context

`expense-limits` was recently introduced with persistence, derived computations, and basic UI/dashboard consumption. Current implementation computes month key once per stream subscription in `watchDerived`, which can become stale if the app remains active across month transition. Dashboard card currently reads daily guidance but still keeps other hardcoded amounts, creating trust risk. Validation uses a single generic error string for different fields.

## Goals / Non-Goals

**Goals:**

- Make derived limits robust across month rollover without needing app restart.
- Improve dashboard consistency for limit guidance representation.
- Provide clear field-specific validation outcomes for income/savings.

**Non-Goals:**

- Redesigning limits screen visual style to match Stitch mock.
- Enforcing hard spending caps.
- Introducing new budgeting models beyond existing income/savings/exclude-recurring.

## Decisions

1. **Month rollover safety in derived stream**
   - Recompute against the active local month key whenever date context changes (or use a periodic/month-trigger refresh strategy) rather than locking month key at initial subscription.
   - Keep recurring deduction source unchanged: enabled + unpaid rows for effective month key.

2. **Dashboard consistency policy**
   - If limits are set, show derived values for associated guidance fields.
   - If limits are unset, show explicit unset markers/copy rather than pseudo-real static numbers in related stat pills.
   - Preserve unrelated hero placeholders unless they are explicitly tied to limits calculations in this change.

3. **Validation behavior**
   - Separate validation messages for income and savings.
   - Maintain ability to clear values by empty input; only reject malformed or invalid numeric text.

## Risks / Trade-offs

- **[Risk]** Month rollover handling introduces additional stream complexity → **Mitigation:** Keep logic localized in repository and add tests for boundary cases.
- **[Risk]** Dashboard textual changes may feel abrupt to users accustomed to static values → **Mitigation:** Use clear “unset” affordances and consistent labels.
- **[Risk]** Validation changes can affect existing user flow expectations → **Mitigation:** Keep permissive empty handling and avoid blocking save when fields intentionally cleared.
