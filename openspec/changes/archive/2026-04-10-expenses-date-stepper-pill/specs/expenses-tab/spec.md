## ADDED Requirements

### Requirement: Daily and Monthly period navigation uses Quick Add date pill pattern

The Expenses tab SHALL present **prev/next** period navigation for **Daily**, **Monthly**, and **Recurring** modes using the same **stepper pill** presentation as Quick Add date selection: a rounded **AppCard** track, a **leading** calendar icon appropriate to the period (day vs month), a **centered** text label for the current period, and **chevron** controls with accessible tooltips. In **Daily** mode the pill SHALL adjust the **selected local calendar day**. In **Monthly** and **Recurring** modes the pill SHALL adjust the **selected calendar month** used for category totals and recurring rows, respectively.

#### Scenario: Daily mode shows day stepper

- **WHEN** the user is in Daily mode on the Expenses tab
- **THEN** the screen SHALL show a stepper pill for the selected calendar day before the expense list

#### Scenario: Monthly mode shows month stepper

- **WHEN** the user is in Monthly mode on the Expenses tab
- **THEN** the screen SHALL show a stepper pill for the selected month and year before the category totals list

#### Scenario: Recurring mode shows month stepper

- **WHEN** the user is in Recurring mode on the Expenses tab
- **THEN** the screen SHALL show a stepper pill for the selected month and year before the recurring payments list

#### Scenario: Steppers share Quick Add visual pattern

- **WHEN** the Expenses tab renders Daily, Monthly, or Recurring stepper pills
- **THEN** their layout and styling SHALL match the shared `DateStepperPill` pattern (card, icon, label, chevrons), allowing full-width usage on Expenses where applicable

### Requirement: Daily view lists expenses for a selected calendar day

In Daily mode, the system MUST let the user change the **selected local calendar day** using the daily stepper and MUST show only expense entries whose **occurred-at** falls within that **local calendar day**, ordered with the **most recent** transaction first.

#### Scenario: List matches selected day only

- **WHEN** the user selects a calendar day in Daily mode
- **THEN** the Expenses tab SHALL list only expenses occurring on that local day

#### Scenario: Prev and next change the day

- **WHEN** the user activates the previous or next control on the daily stepper
- **THEN** the selected calendar day SHALL change by one day and the list SHALL update accordingly

## REMOVED Requirements

### Requirement: Daily view lists expenses grouped by day

In Daily mode, the system MUST show a list of expense entries grouped by local calendar day, ordered with the most recent day first and the most recent expense first within each day.

#### Scenario: Daily list groups by calendar day

- **WHEN** expenses exist across multiple calendar days
- **THEN** the Expenses tab SHALL group them by day headings (e.g. Today / date label) and display items under the correct day

**Reason:** Replaced by a single selected calendar day and stepper navigation; multi-day grouping in one scroll is no longer the Daily mode behavior.

**Migration:** Users browse prior days using the daily stepper instead of scrolling mixed days in one list.
