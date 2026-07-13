## MODIFIED Requirements

### Requirement: Indicative daily amount from calendar month length

When spendable pool is defined for the current local month with **D** days (28–31), the system MUST derive **Daily plan** and a **Pace snapshot write value** in minor units:

- **Daily plan** — integer division of spendable pool by **D** (`pool ~/ D`), or **zero** when pool is non-positive. Daily plan MUST ignore month spent.
- **Pace snapshot write value** — used only when creating the locked Pace row for a local day. Let `spentBeforeToday` be month spent excluding today’s local-date expenses. Let `daysLeftIncludingToday` be `D − dayOfMonth + 1` (**including today**). The write value MUST be `max(0, pool − spentBeforeToday) ~/ daysLeftIncludingToday` when remaining is positive and `daysLeftIncludingToday` is positive; otherwise **zero**.

The Pace value **shown on Home for the current day** MUST be the **locked daily Pace snapshot**, not a live mid-day recomputation that includes today’s spend in the leftover.

#### Scenario: February length affects Daily plan divisor

- **WHEN** the current month is February in a leap year and pool is positive
- **THEN** Daily plan MUST use divisor **29**

#### Scenario: Daily plan ignores month spent

- **WHEN** spendable pool is 3000 minor units and the month has 30 days
- **AND** current-month spent is greater than zero but less than the pool
- **THEN** Daily plan MUST remain `3000 ~/ 30`

#### Scenario: Snapshot write uses spent before today and days left including today

- **WHEN** spendable pool is 3000 minor units, the month has 30 days, local day-of-month is **10**, spent before today is **1100**, and spent today is **400**
- **THEN** daysLeftIncludingToday MUST be **21**
- **AND** the Pace snapshot write value MUST be `1900 ~/ 21`
- **AND** MUST NOT use `1900 ~/ 20` (must not exclude today from the divisor)
- **AND** MUST NOT use leftover that subtracts today’s 400

#### Scenario: Steady spend keeps Pace equal to Daily plan

- **WHEN** spendable pool is 300, the month has 30 days, Daily plan is 10
- **AND** the user spent exactly 10 on each of the first 9 days
- **AND** local day-of-month is **10** with no spend yet today
- **THEN** the Pace snapshot write value MUST be `210 ~/ 21` which equals **10**

#### Scenario: Last day yields leftover as pace

- **WHEN** local day-of-month equals **D** and `pool − spentBeforeToday` is **150**
- **THEN** daysLeftIncludingToday MUST be **1**
- **AND** the Pace snapshot write value MUST be **150**

#### Scenario: Non-positive remaining before today yields zero pace write value

- **WHEN** spent before today is greater than or equal to spendable pool
- **THEN** the Pace snapshot write value MUST be **zero**
- **AND** Daily plan MUST still equal `pool ~/ D` when pool is positive
