## MODIFIED Requirements

### Requirement: Indicative daily amount from calendar month length

When spendable pool is defined for the current local month with **D** days (28–31), the system MUST derive **Daily plan** and a **Pace snapshot write value** in minor units:

- **Daily plan** — integer division of spendable pool by **D** (`pool ~/ D`), or **zero** when pool is non-positive. Daily plan MUST ignore month spent.
- **Pace snapshot write value** — used only when creating the locked Pace row for a local day (see daily-pace-history). Let `spentBeforeToday` be month spent excluding today’s local-date expenses. Let `daysAfterToday` be `D − dayOfMonth` (**excluding today**). The write value MUST be `max(0, pool − spentBeforeToday) ~/ daysAfterToday` when remaining is positive and `daysAfterToday` is positive; otherwise **zero**.

The Pace value **shown on Home for the current day** MUST be the **locked daily Pace snapshot**, not a continuously recomputed live remaining÷days figure that includes today’s spend.

#### Scenario: February length affects Daily plan divisor

- **WHEN** the current month is February in a leap year and pool is positive
- **THEN** Daily plan MUST use divisor **29**

#### Scenario: Daily plan ignores month spent

- **WHEN** spendable pool is 3000 minor units and the month has 30 days
- **AND** current-month spent is greater than zero but less than the pool
- **THEN** Daily plan MUST remain `3000 ~/ 30`

#### Scenario: Snapshot write uses spent before today and days after today

- **WHEN** spendable pool is 3000 minor units, the month has 30 days, local day-of-month is **10**, spent before today is **1100**, and spent today is **400**
- **THEN** the Pace snapshot write value MUST be `1900 ~/ 20`
- **AND** MUST NOT use `1500 ~/ 20` (must ignore today’s 400)

#### Scenario: Last day yields zero pace write value

- **WHEN** local day-of-month equals **D**
- **THEN** daysAfterToday MUST be **0**
- **AND** the Pace snapshot write value MUST be **zero**

#### Scenario: Non-positive remaining before today yields zero pace write value

- **WHEN** spent before today is greater than or equal to spendable pool
- **THEN** the Pace snapshot write value MUST be **zero**
- **AND** Daily plan MUST still equal `pool ~/ D` when pool is positive

### Requirement: Dashboard home shows limits summary details

The system MUST show a limits summary section on dashboard home that includes monthly total expense, remaining or overspent monthly amount, current savings set, **Daily plan**, and the **locked Pace for today** (from the daily Pace snapshot). Home MUST also present **today’s expense** against that locked Pace. Daily plan and Pace MUST remain associated with the monthly remaining/overspent presentation (paired or adjacent daily row). Savings MUST remain separate from that dual-daily presentation.

Home MUST NOT lower or recalculate the displayed Pace for today when the user adds expenses today. When today’s expense exceeds locked Pace, Home MUST indicate an over-Pace state (styling and/or exceed amount) while Pace remains the locked value.

#### Scenario: Dashboard renders all requested details

- **WHEN** the user opens dashboard home and limits are configured
- **THEN** the limits summary SHALL display monthly total expense, remaining or overspent amount, current savings set, Daily plan, locked Pace for today, and today’s expense context for Pace comparison

#### Scenario: Dual daily nested under remaining

- **WHEN** limits are configured
- **THEN** Daily plan and Pace SHALL appear as a paired (or adjacent) row under the monthly remaining/overspent presentation

#### Scenario: Pace stays locked after today spend

- **WHEN** today’s locked Pace is **500**
- **AND** the user records expenses today totaling more than **500**
- **THEN** the displayed Pace SHALL remain **500**
- **AND** Home SHALL show an over-Pace indication relative to today’s spend

#### Scenario: Remaining monthly amount is derived from guidance and spending

- **WHEN** monthly total expense and spendable monthly guidance are available
- **THEN** remaining monthly amount SHALL be derived from those values (not a separately persisted field)

#### Scenario: Unset limits show explicit placeholders

- **WHEN** income/savings/limits are not configured
- **THEN** the corresponding limits summary fields SHALL show explicit unset placeholders rather than misleading numeric values

## ADDED Requirements

### Requirement: Home Pace comes from daily snapshot ensure

When limits are configured and the user views Home, the system MUST ensure a Pace snapshot exists for the current local date (creating it if missing) and MUST bind the Home Pace display to that snapshot’s `paceMinor`.

#### Scenario: First Home open of the day locks Pace

- **WHEN** limits are configured and no snapshot exists for today
- **AND** the user opens Home
- **THEN** the system SHALL create today’s Pace snapshot
- **AND** Home SHALL display that snapshot’s Pace
