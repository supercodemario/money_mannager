## MODIFIED Requirements

### Requirement: Indicative daily amount from calendar month length

When spendable pool is defined for the current month and the number of days in that month is **D** (28–31), the system MUST derive **indicative daily spend** from **remaining monthly guidance**, not from the raw spendable pool alone. Remaining MUST be **spendablePool − currentMonthSpent** using the same month spent total as the dashboard limits summary. Indicative daily MUST be **integer division** of `max(0, remaining)` by **D** (floor toward zero). When remaining is zero or negative (overspent), indicative daily MUST be **zero**.

#### Scenario: February length affects divisor

- **WHEN** the current month is February in a leap year and remaining is positive
- **THEN** the divisor for daily guidance MUST be **29** for that month

#### Scenario: Paid recurring reduces indicative daily via spent

- **WHEN** exclude-unpaid-recurring is true, a recurring bill was unpaid (reserved in the pool), and the user marks it paid so its amount is included in current-month spent and no longer in the unpaid reservation
- **THEN** indicative daily MUST equal `max(0, spendablePool − currentMonthSpent) ~/ D` and MUST NOT return to the pre-reservation pool-only daily that ignores that spent amount

#### Scenario: Unpaid reservation without spend keeps daily reduced

- **WHEN** exclude-unpaid-recurring is true, enabled recurring amounts are unpaid for the month, and current-month spent does not yet include those amounts
- **THEN** indicative daily MUST use the reduced spendable pool (with unpaid reservation) minus spent, divided by **D**

#### Scenario: Overspent yields zero daily

- **WHEN** current-month spent is greater than spendable pool
- **THEN** indicative daily MUST be **zero**

## ADDED Requirements

### Requirement: Indicative daily stays aligned with remaining summary

Wherever the product shows indicative daily alongside monthly remaining/overspent guidance, both MUST be derived from the same spendable pool and the same current-month spent total for the active scope.

#### Scenario: Dashboard daily matches remaining math

- **WHEN** dashboard home shows remaining (or overspent) and indicative daily for configured limits
- **THEN** indicative daily MUST be consistent with `max(0, spendablePool − monthlySpent) ~/ daysInMonth` for that same pool and spent
