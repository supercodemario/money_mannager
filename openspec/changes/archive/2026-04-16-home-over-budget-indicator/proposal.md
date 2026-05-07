## Why

Users can currently exceed monthly spendable guidance on Home without a clear warning state. The card still appears "On Track" and caps visual cues at 100%, which hides overspending risk and reduces trust in limit guidance.

## What Changes

- Add an explicit over-budget state on the Home monthly spending card when monthly spent exceeds monthly spendable guidance.
- Show overspending with warning semantics:
  - red status treatment,
  - over-budget wording,
  - explicit exceeded amount and exceeded percent.
- Update monthly progress and remaining sections so they communicate overage instead of clamping to non-negative remaining.
- Keep behavior unchanged when limits are not configured.

## Capabilities

### New Capabilities

- `home-over-budget-indicator`: Detect and present over-budget states on Home monthly spending with explicit exceeded amount and percent messaging.

### Modified Capabilities

- `expense-limits`: Home guidance presentation includes exceed-state communication when spendable guidance is breached.

## Impact

- Affected code: `dashboard_monthly_spending_card.dart`, related dashboard string tokens, and shared visual status styling.
- No schema migration expected; calculations reuse existing derived limit/spending data.
- UX impact: users receive clear red warning cues and quantified exceed details when spending exceeds guidance.