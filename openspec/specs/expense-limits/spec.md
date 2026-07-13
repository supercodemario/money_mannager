# expense-limits Specification

## Purpose

Users set **monthly income** and optional **savings** and **exclude unpaid recurring** preferences so the app can show **spendable pool**, **Daily plan**, and **Pace / day** guidance for the current local month. Values are **guidance only**—they do not block recording expenses.

## Requirements

### Requirement: Expense limit preferences are persisted locally

The system MUST persist, per user profile (or equivalent single-user scope used by the app), at least: optional **monthly income** in minor currency units, optional **monthly savings reservation** in minor units, and a boolean **exclude unpaid enabled recurring** defaulting to **false**. Values MUST survive app restarts.

#### Scenario: User saves limits from the limits screen

- **WHEN** the user enters or updates income, savings, and exclude-recurring options and commits (save)
- **THEN** the system SHALL store the values in local persistence associated with the active profile

#### Scenario: Fresh install has no income until set

- **WHEN** the user has never saved income
- **THEN** the system SHALL treat monthly income as unset for guidance purposes until provided

### Requirement: Spendable pool uses income savings and optional recurring deduction

For the **current local calendar month**, when monthly income is set, the system MUST compute a **spendable pool** in minor units as **max(0, I − S − R)** where **I** is monthly income minor, **S** is monthly savings minor (0 if unset), and **R** is the recurring deduction sum when exclude-unpaid-recurring is true (otherwise **R = 0**). **R** MUST be the sum of suggested amounts for recurring templates that are **scheduling-enabled** and **unpaid** for that month’s occurrence.

#### Scenario: Exclude recurring sums only unpaid enabled templates

- **WHEN** exclude-unpaid-recurring is true and a recurring template is scheduling-disabled
- **THEN** that template MUST NOT contribute to the deducted sum

#### Scenario: Unpaid occurrence required for deduction

- **WHEN** exclude-unpaid-recurring is true and a template is enabled but already paid for the current month
- **THEN** that template MUST NOT contribute to the deducted sum for that month

### Requirement: Indicative daily amount from calendar month length

When spendable pool is defined for the current local month with **D** days (28–31), the system MUST derive **Daily plan** and a **Pace snapshot write value** in minor units:

- **Daily plan** — integer division of spendable pool by **D** (`pool ~/ D`), or **zero** when pool is non-positive. Daily plan MUST ignore month spent.
- **Pace snapshot write value** — used only when creating the locked Pace row for a local day (see daily-pace-history). Let `spentBeforeToday` be month spent excluding today’s local-date expenses. Let `daysLeftIncludingToday` be `D − dayOfMonth + 1` (**including today**). The write value MUST be `max(0, pool − spentBeforeToday) ~/ daysLeftIncludingToday` when remaining is positive and `daysLeftIncludingToday` is positive; otherwise **zero**.

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

### Requirement: Dashboard limits summary distinguishes remaining vs overspent

The dashboard limits summary MUST distinguish non-exceed and exceed states by labeling the monthly balance row as remaining when under guidance and overspent when above guidance.

#### Scenario: Non-exceed state keeps remaining label

- **WHEN** monthly spent is less than or equal to monthly spendable guidance
- **THEN** the monthly balance row SHALL be labeled as remaining and show the remaining amount

#### Scenario: Exceed state switches to overspent label

- **WHEN** monthly spent is greater than monthly spendable guidance
- **THEN** the monthly balance row SHALL be labeled as overspent and show the absolute exceeded amount

### Requirement: Dashboard guidance messaging includes exceeded percent

The dashboard monthly guidance message MUST include exceeded percent in over-budget state while preserving used-percent messaging in non-exceed state.

#### Scenario: Non-exceed guidance shows used percent

- **WHEN** monthly spent is less than or equal to monthly spendable guidance
- **THEN** the guidance subtitle SHALL show used percentage of monthly spendable guidance

#### Scenario: Exceed guidance shows exceeded percent

- **WHEN** monthly spent is greater than monthly spendable guidance
- **THEN** the guidance subtitle or companion line SHALL include exceeded percentage with explicit positive overage wording

### Requirement: Home dual daily opens month day listing

When limits are configured, the Daily plan / Pace / day row on dashboard home MUST be tappable and MUST navigate to the month day spend listing for the current local month.

#### Scenario: Tap opens listing

- **WHEN** the user taps the Daily plan / Pace / day row on Home
- **THEN** the app SHALL open the month day spend listing for the current local month

### Requirement: Home Pace comes from daily snapshot ensure

When limits are configured and the user views Home, the system MUST ensure a Pace snapshot exists for the current local date (creating it if missing, after month expense data is available) and MUST bind the Home Pace display to that snapshot’s `paceMinor`.

#### Scenario: First Home open of the day locks Pace

- **WHEN** limits are configured and no snapshot exists for today
- **AND** the user opens Home
- **THEN** the system SHALL create today’s Pace snapshot
- **AND** Home SHALL display that snapshot’s Pace
