# expense-limits Specification

## Purpose

Users set **monthly income** and optional **savings** and **exclude unpaid recurring** preferences so the app can show **indicative** spendable pool and **daily guidance** for the current local month. Values are **guidance only**—they do not block recording expenses.
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

When spendable pool is defined for the current month and the number of days in that month is **D** (28–31), the system MUST derive an **indicative daily spend** in minor units using **integer division** of pool by **D** (floor toward zero), unless pool is non-positive in which case the indicative daily MUST be **zero**.

#### Scenario: February length affects divisor

- **WHEN** the current month is February in a leap year
- **THEN** the divisor for daily guidance MUST be **29** for that month

### Requirement: Guidance is non-blocking

The indicative daily and monthly pool values MUST be presented as **guidance** for understanding sustainable pace. The system MUST NOT prevent saving expenses or recurring mark-paid actions solely because they exceed the indicative daily amount in this capability.

#### Scenario: Overspend allowed

- **WHEN** the user records an expense larger than the indicative daily amount
- **THEN** the app SHALL still allow the expense to be saved per existing expense flows

### Requirement: Limits detail screen captures inputs

The system MUST provide a **limits detail** screen reachable from Settings where the user can enter monthly income, optional monthly savings, and toggle exclude-unpaid-recurring, and save. The screen MUST show derived **spendable pool** and **indicative daily** when enough inputs exist to compute them. The limits detail screen MUST present these controls using the approved Stitch v3 composition: a prominent monthly income section, side-by-side spendable summary cards, a savings-goal card that supports percentage-goal adjustment, a recurring-subtraction toggle card, and a primary save action. Derived summaries MUST refresh in real time from the current on-screen inputs.

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
- **THEN** the monthly and daily spendable summaries SHALL update immediately from the current inputs while continuing to apply the same existing expense-limits derivation rules for the active month

### Requirement: Dashboard home shows limits summary details
The system MUST show a limits summary section on dashboard home that includes monthly total expense, remaining monthly amount, current savings set, and current daily limit using locally persisted preferences and derived guidance values.

#### Scenario: Dashboard renders all requested details
- **WHEN** the user opens dashboard home
- **THEN** the limits summary SHALL display monthly total expense, remaining monthly amount, current savings set, and current daily limit

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

