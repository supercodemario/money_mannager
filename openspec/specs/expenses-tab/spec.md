# expenses-tab Specification

## Purpose

The Expenses tab lets users switch among Daily, Monthly, and Recurring views of spending and obligations, with a mode switcher that follows the streamlined pill design (sliding indicator, no segment check icons).

## Requirements

### Requirement: Expenses tab shows Daily, Monthly, and Recurring switches

The system MUST provide an Expenses tab screen that allows the user to switch between **Daily**, **Monthly**, and **Recurring payments** views of expense-related information.

#### Scenario: User switches view mode

- **WHEN** the user selects Daily, Monthly, or Recurring payments in the Expenses tab
- **THEN** the Expenses tab SHALL update to show the corresponding view

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

### Requirement: Monthly view lists totals grouped by category

In Monthly mode, the system MUST show a list of categories with the total amount spent in the selected month for each category, derived from the locally persisted expenses.

#### Scenario: Category totals for a month

- **WHEN** the user views Monthly mode for a month with saved expenses
- **THEN** the Expenses tab SHALL list category totals computed by summing `amount_minor` for that month grouped by `category_id`

### Requirement: Recurring payments view lists monthly recurring items with paid state

When **Recurring payments** mode is selected, the system MUST show recurring payment obligations for the **selected calendar month** (with navigation consistent with Monthly mode where applicable), including each item’s title, category, due state (paid vs unpaid), overdue indication when applicable, and **mark as paid** for unpaid items.

#### Scenario: Recurring mode is distinct from Daily and Monthly

- **WHEN** the user selects Recurring payments
- **THEN** the screen SHALL NOT show only the Daily grouped-by-day expense list or the Monthly category totals list; it SHALL show the recurring payments list

### Requirement: Expenses data is fetched from local storage

Both Daily and Monthly views MUST read expenses from the local Drift/SQLite database via repository methods (not hardcoded sample data).

#### Scenario: Recent save appears in Expenses tab

- **WHEN** the user saves an expense in Quick Add
- **THEN** the saved expense SHALL be retrievable from local storage and MAY appear in the Daily or Monthly Expenses view without restarting the app

### Requirement: Expenses mode switcher matches streamlined pill design

The Expenses tab MUST present the Daily, Monthly, and Recurring mode control as a full-width **pill-shaped track** with **inner padding** (equivalent to a thin inset from the track edge), a **rounded selection indicator** that occupies approximately one third of the inner width, and **labels** that reflect selected vs unselected states with sufficient contrast. The selection indicator MUST **move** between the three positions when the user changes mode using a short animated transition.

#### Scenario: User sees pill track and sliding selection

- **WHEN** the Expenses tab is displayed
- **THEN** the mode control SHALL show a continuous track with three equal segments and a single rounded indicator aligned to the active segment

#### Scenario: User changes mode and indicator animates

- **WHEN** the user switches from one mode to another
- **THEN** the selection indicator SHALL animate to the new segment position

### Requirement: Selection without segment icons

The active mode MUST be clear from the **sliding indicator** and **label contrast** alone. The mode control SHALL NOT require checkmarks or other icons on segment labels to communicate selection.

#### Scenario: No auxiliary selection icons

- **WHEN** any of Daily, Monthly, or Recurring is active
- **THEN** the mode control SHALL NOT show a check icon (or equivalent) on the segment labels

### Requirement: Expense classification uses selected category bucket

When the user records an expense by selecting a category, the system MUST derive and persist the expense’s 50/30/20 classification from that category’s assigned bucket without requiring separate bucket input.

#### Scenario: Category selection auto-classifies expense

- **WHEN** the user selects a category while adding an expense
- **THEN** the expense SHALL be classified under the category’s bucket (`needs`, `wants`, or `savings_debt`) automatically

#### Scenario: Bucket change affects future expense classification

- **WHEN** a category’s bucket assignment is updated
- **THEN** new expenses recorded with that category SHALL use the updated bucket assignment
