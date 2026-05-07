## ADDED Requirements

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

The system MUST provide a **limits detail** screen reachable from Settings where the user can enter monthly income, optional monthly savings, and toggle exclude-unpaid-recurring, and save. The screen MUST show derived **spendable pool** (or equivalent) and **indicative daily** when enough inputs exist to compute them.

#### Scenario: Navigate from Settings Limits card

- **WHEN** the user opens the limits detail screen from the compact Settings Limits summary card
- **THEN** the user SHALL see the inputs and saved values consistent with persistence
