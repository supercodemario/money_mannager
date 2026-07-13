## MODIFIED Requirements

### Requirement: Indicative daily amount from calendar month length

When spendable pool is defined for the current local month with **D** days (28–31), the system MUST derive two guidance values in minor units:

- **Daily plan** — integer division of spendable pool by **D** (`pool ~/ D`), or **zero** when pool is non-positive.
- **Pace / day** — let **remaining** be `spendablePool − currentMonthSpent` (same remaining as the dashboard monthly balance). Let **daysAfterToday** be `D − dayOfMonth` for the current local date (**excluding today**). Pace / day MUST be `remaining ~/ daysAfterToday` when remaining is positive and daysAfterToday is positive; otherwise Pace / day MUST be **zero**.

#### Scenario: February length affects Daily plan divisor

- **WHEN** the current month is February in a leap year and pool is positive
- **THEN** Daily plan MUST use divisor **29**

#### Scenario: Daily plan ignores month spent

- **WHEN** spendable pool is 3000 minor units and the month has 30 days
- **AND** current-month spent is greater than zero but less than the pool
- **THEN** Daily plan MUST remain `3000 ~/ 30`

#### Scenario: Pace uses remaining and days after today

- **WHEN** spendable pool is 3000 minor units, the month has 30 days, local day-of-month is **10**, and current-month spent is **1100** (remaining **1900**)
- **THEN** daysAfterToday MUST be **20**
- **AND** Pace / day MUST be `1900 ~/ 20`

#### Scenario: Last day yields zero pace

- **WHEN** local day-of-month equals **D**
- **THEN** daysAfterToday MUST be **0**
- **AND** Pace / day MUST be **zero**

#### Scenario: Overspent yields zero pace

- **WHEN** current-month spent is greater than spendable pool
- **THEN** Pace / day MUST be **zero**
- **AND** Daily plan MUST still equal `pool ~/ D` when pool is positive

### Requirement: Dashboard home shows limits summary details

The system MUST show a limits summary section on dashboard home that includes monthly total expense, remaining or overspent monthly amount, current savings set, and both **Daily plan** and **Pace / day** using locally persisted preferences and derived guidance values. Daily plan and Pace / day MUST be presented nested under the monthly remaining/overspent block (not as a single standalone daily pill that replaces that pairing). Savings MUST remain separate from that dual-daily row.

#### Scenario: Dashboard renders all requested details

- **WHEN** the user opens dashboard home and limits are configured
- **THEN** the limits summary SHALL display monthly total expense, remaining or overspent amount, current savings set, Daily plan, and Pace / day

#### Scenario: Dual daily nested under remaining

- **WHEN** limits are configured
- **THEN** Daily plan and Pace / day SHALL appear as a paired row under the monthly remaining/overspent presentation

#### Scenario: Remaining monthly amount is derived from guidance and spending

- **WHEN** monthly total expense and spendable monthly guidance are available
- **THEN** remaining monthly amount SHALL be derived from those values (not a separately persisted field)

#### Scenario: Unset limits show explicit placeholders

- **WHEN** income/savings/limits are not configured
- **THEN** the corresponding limits summary fields SHALL show explicit unset placeholders rather than misleading numeric values

### Requirement: Guidance is non-blocking

The Daily plan, Pace / day, and monthly pool values MUST be presented as **guidance** for understanding sustainable pace. The system MUST NOT prevent saving expenses or recurring mark-paid actions solely because they exceed Daily plan or Pace / day in this capability.

#### Scenario: Overspend allowed

- **WHEN** the user records an expense larger than Daily plan or Pace / day
- **THEN** the app SHALL still allow the expense to be saved per existing expense flows

### Requirement: Limits detail screen captures inputs

The system MUST provide a **limits detail** screen reachable from Settings where the user can enter monthly income, optional monthly savings, and toggle exclude-unpaid-recurring, and save. The screen MUST show derived **spendable pool** and **Daily plan** when enough inputs exist to compute them. The limits detail screen MUST present these controls using the approved Stitch v3 composition: a prominent monthly income section, side-by-side spendable summary cards, a savings-goal card that supports percentage-goal adjustment, a recurring-subtraction toggle card, and a primary save action. Derived summaries MUST refresh in real time from the current on-screen inputs.

#### Scenario: Navigate from Settings Limits card

- **WHEN** the user opens the limits detail screen from the compact Settings Limits summary card
- **THEN** the user SHALL see limits inputs and saved values consistent with persistence

#### Scenario: Stitch v3 composition is present on limits detail

- **WHEN** the limits detail screen is rendered
- **THEN** the user SHALL see the Stitch v3 layout with monthly income section, spendable summary cards, savings-goal card with percentage control, recurring-subtraction toggle card, and primary save action

#### Scenario: Savings percentage interaction updates savings amount

- **WHEN** the user adjusts the savings percentage goal control on the limits detail screen
- **THEN** the screen SHALL update the savings amount input consistently with that percentage against the entered monthly income

#### Scenario: Limits summaries remain derived from current inputs

- **WHEN** the user changes income, savings, or recurring subtraction options
- **THEN** the monthly and Daily plan summaries SHALL update immediately from the current inputs while continuing to apply the same existing expense-limits derivation rules for the active month

## ADDED Requirements

### Requirement: Home dual daily opens month day listing

When limits are configured, the Daily plan / Pace / day row on dashboard home MUST be tappable and MUST navigate to the month day spend listing for the current local month.

#### Scenario: Tap opens listing

- **WHEN** the user taps the Daily plan / Pace / day row on Home
- **THEN** the app SHALL open the month day spend listing for the current local month
