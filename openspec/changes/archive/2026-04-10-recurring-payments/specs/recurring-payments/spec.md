## ADDED Requirements

### Requirement: Recurring payment templates are stored locally

The system MUST persist **recurring payment** definitions on device (Drift/SQLite) with at least: a stable unique id, a user-visible **title** (distinct from category label), `category_id` (from the app category catalog), suggested amount in minor units, `currency_code`, and **day of month** (1–31) for monthly due date. Multiple recurring definitions MAY share the same `category_id` and MUST remain distinguishable by their own ids and titles.

#### Scenario: Create recurring payment

- **WHEN** the user creates a recurring payment with title, category, suggested amount, and day of month
- **THEN** the system SHALL persist a template row retrievable for the Recurring payments list and home dashboard

### Requirement: Monthly occurrence and paid state

For each calendar month and each recurring template, the system MUST represent whether that obligation is **paid** for that month by associating at most one **fulfillment** with at most one **expense** row. Unpaid months MUST NOT have a linked expense.

#### Scenario: Mark as paid creates an expense

- **WHEN** the user marks a recurring payment as paid for a given month
- **THEN** the system SHALL insert a persisted expense row (visible in Daily and Monthly views) and SHALL record that the recurring occurrence for that month is fulfilled

#### Scenario: Editable amount when paying

- **WHEN** the user confirms mark as paid
- **THEN** the system SHALL allow editing the amount before saving the expense (to support variable bills such as utilities)

### Requirement: Expenses may reference a recurring template id

When an expense is created from the recurring **mark as paid** flow, the expense row MUST include a nullable reference to the recurring template id (or equivalent fulfillment link) so fulfillment is explicit and not inferred from category alone.

#### Scenario: Same category, different recurring lines

- **WHEN** two recurring templates share the same `category_id`
- **THEN** marking one as paid MUST NOT imply the other is paid, and SHALL link only the expense created for that template

### Requirement: Overdue and due-day presentation

For the **selected calendar month**, for each unpaid recurring occurrence, the system MUST compute whether the due date is **past** (overdue) using the user’s local calendar: compare `day_of_month` to the template’s due day within that month. If the current local day is greater than the due day and the occurrence is unpaid, the UI MUST show an **overdue** indication. If the current local day equals the due day and unpaid, the system MAY treat that as **due today** (for future notification hooks).

#### Scenario: Overdue when day passed

- **WHEN** today’s local date is after the due day in the month and the occurrence is unpaid
- **THEN** the Recurring payments list and home dashboard SHALL show overdue indication for that item

### Requirement: Home dashboard and Expenses Recurring use the same data

The home dashboard MUST NOT use static placeholder bill data. Upcoming and overdue sections MUST read the same persisted recurring occurrence data as the Expenses tab **Recurring payments** mode. The home view MUST present **two labeled sections** (e.g. **Overdue** and **Upcoming**) for unpaid items so users can scan quickly at a glance.

#### Scenario: Consistency across surfaces

- **WHEN** the user marks a recurring payment as paid from either the home dashboard or the Expenses Recurring view
- **THEN** both surfaces SHALL reflect the updated paid state without contradictory rows

### Requirement: Cadence is monthly only in this capability

Recurring payments MUST use **monthly** scheduling by day-of-month only. Other cadences (e.g. weekly) are out of scope for this capability but MAY be added later without breaking stored monthly rows.

#### Scenario: Monthly scope

- **WHEN** the user selects a calendar month in Recurring payments
- **THEN** the system SHALL list occurrences for that month derived from monthly templates only

### Requirement: Recurring list shows paid and unpaid

The Expenses **Recurring payments** view MUST list recurring items for the selected month with a clear **paid** or **unpaid** state. Paid items MUST remain visible in that list (not only in Daily/Monthly expense lists).

#### Scenario: Paid visible in recurring list

- **WHEN** a recurring payment has been marked paid for the selected month
- **THEN** the Recurring payments list SHALL show it as paid while the corresponding expense appears in Daily and Monthly views
