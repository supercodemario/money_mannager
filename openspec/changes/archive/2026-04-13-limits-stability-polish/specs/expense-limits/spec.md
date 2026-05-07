## MODIFIED Requirements

### Requirement: Limits detail screen captures inputs

The system MUST provide a **limits detail** screen reachable from Settings where the user can enter monthly income, optional monthly savings, and toggle exclude-unpaid-recurring, and save. The screen MUST show derived **spendable pool** (or equivalent) and **indicative daily** when enough inputs exist to compute them. Validation feedback MUST be field-specific for income and savings inputs (not a single ambiguous error for both fields).

#### Scenario: Navigate from Settings Limits card

- **WHEN** the user opens the limits detail screen from the compact Settings Limits summary card
- **THEN** the user SHALL see the inputs and saved values consistent with persistence

#### Scenario: Invalid income and savings feedback is specific

- **WHEN** the user enters invalid income text or invalid savings text
- **THEN** the system SHALL show a validation message that identifies the problematic field type (income vs savings)

### Requirement: Spendable pool uses income savings and optional recurring deduction

For the **current local calendar month**, when monthly income is set, the system MUST compute a **spendable pool** in minor units as **max(0, I − S − R)** where **I** is monthly income minor, **S** is monthly savings minor (0 if unset), and **R** is the recurring deduction sum when exclude-unpaid-recurring is true (otherwise **R = 0**). **R** MUST be the sum of suggested amounts for recurring templates that are **scheduling-enabled** and **unpaid** for that month’s occurrence. Derived values MUST remain correct when the app crosses into a new local month without requiring restart.

#### Scenario: Exclude recurring sums only unpaid enabled templates

- **WHEN** exclude-unpaid-recurring is true and a recurring template is scheduling-disabled
- **THEN** that template MUST NOT contribute to the deducted sum

#### Scenario: Unpaid occurrence required for deduction

- **WHEN** exclude-unpaid-recurring is true and a template is enabled but already paid for the current month
- **THEN** that template MUST NOT contribute to the deducted sum for that month

#### Scenario: Month rollover updates recurring deduction basis

- **WHEN** the app remains open across local calendar month transition
- **THEN** the derived spendable pool and daily guidance SHALL recalculate using the new month key and new month day-count

## ADDED Requirements

### Requirement: Dashboard daily guidance reflects limits state consistently

Where the home spending card displays a **daily limit/guidance** value sourced from expense limits, the value SHALL be consistent with current derived limits when limits are set, and SHALL display a clear unset indicator when limits are not configured.

#### Scenario: Limits set shows derived daily value

- **WHEN** expense limits are configured with valid income
- **THEN** the home spending card daily guidance SHALL show the derived indicative daily amount

#### Scenario: Limits unset shows explicit unset state

- **WHEN** expense limits are unset (no valid monthly income)
- **THEN** the home spending card daily guidance SHALL show an explicit unset placeholder rather than a pseudo-real static amount
