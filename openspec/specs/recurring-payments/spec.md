# recurring-payments Specification

## Purpose

TBD - created by archiving change recurring-payments. Update Purpose after archive.

## Requirements

### Requirement: Recurring payment templates are stored locally

The system MUST persist **recurring payment** definitions on device (Drift/SQLite) with at least: a stable unique id, a user-visible **title** (distinct from category label), `category_id` (from the app category catalog), suggested amount in minor units, `currency_code`, and **day of month** (1–31) for monthly due date. Multiple recurring definitions MAY share the same `category_id` and MUST remain distinguishable by their own ids and titles.

#### Scenario: Create recurring payment

- **WHEN** the user creates a recurring payment with title, category, suggested amount, and day of month
- **THEN** the system SHALL persist a template row retrievable for the Recurring payments list and home dashboard

### Requirement: Optional inclusive end month

The system MAY persist an optional inclusive **end month** for a recurring template (local calendar month encoded as `YYYY-MM`). When set, that template MUST NOT be listed for calendar months strictly after the end month.

#### Scenario: Template stops after end month

- **WHEN** a recurring template has an end month set and the user views a later calendar month
- **THEN** that template SHALL NOT appear in the Recurring payments list for that month

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

The home dashboard MUST NOT use static placeholder bill data. Upcoming and overdue sections MUST read the same persisted recurring occurrence data as the Expenses tab **Recurring payments** mode, **limited to templates whose scheduling enabled flag is true**. Templates with scheduling disabled MUST NOT contribute rows to those sections. The home view MUST present **two labeled sections** (e.g. **Overdue** and **Upcoming**) for unpaid items so users can scan quickly at a glance.

#### Scenario: Consistency across surfaces

- **WHEN** the user marks a recurring payment as paid from either the home dashboard or the Expenses Recurring view
- **THEN** both surfaces SHALL reflect the updated paid state without contradictory rows

#### Scenario: Disabled template omitted from both surfaces

- **WHEN** a template has scheduling disabled
- **THEN** it SHALL NOT appear in the home dashboard overdue or upcoming sections nor in the Expenses tab Recurring payments list until scheduling is enabled again

### Requirement: Cadence is monthly only in this capability

Recurring payments MUST use **monthly** scheduling by day-of-month only. Other cadences (e.g. weekly) are out of scope for this capability but MAY be added later without breaking stored monthly rows.

#### Scenario: Monthly scope

- **WHEN** the user selects a calendar month in Recurring payments
- **THEN** the system SHALL list occurrences for that month derived from monthly templates only

### Requirement: Recurring list shows paid and unpaid

The Expenses **Recurring payments** view MUST list recurring items for the selected month **for templates with scheduling enabled only**, with a clear **paid** or **unpaid** state. Paid items MUST remain visible in that list (not only in Daily/Monthly expense lists).

#### Scenario: Paid visible in recurring list

- **WHEN** a recurring payment has been marked paid for the selected month and its template has scheduling enabled
- **THEN** the Recurring payments list SHALL show it as paid while the corresponding expense appears in Daily and Monthly views

### Requirement: Recurring templates persist a scheduling enabled flag

The system MUST persist a boolean **scheduling enabled** flag on each recurring template. New templates MUST default to **enabled**. Existing templates after migration MUST be **enabled** unless the user turns them off.

#### Scenario: New template is enabled by default

- **WHEN** the user saves a new recurring template
- **THEN** the persisted row SHALL have scheduling enabled **true**

#### Scenario: Migration preserves behavior for existing data

- **WHEN** the app runs after the schema change that introduces the flag
- **THEN** every existing recurring template row SHALL be stored with scheduling enabled **true** so current lists behave as before until the user disables a template

### Requirement: Disabled templates do not appear on home or Expenses Recurring

When scheduling enabled is **false** for a template, that template MUST NOT appear in the home dashboard recurring sections (overdue or upcoming) nor in the Expenses tab **Recurring payments** list for any calendar month, **including** when the occurrence for the selected month would otherwise be **unpaid**. Exclusion MUST take effect **immediately** after the user disables the template (same app session, without restart).

#### Scenario: Unpaid current month disappears when disabled

- **WHEN** the user disables a template that is still unpaid for the currently selected or current calendar month
- **THEN** that template SHALL disappear from the Expenses Recurring list and from the home recurring sections immediately

#### Scenario: Re-enable restores visibility

- **WHEN** the user enables a previously disabled template
- **THEN** it SHALL again appear in Expenses Recurring and home sections according to the same rules as other enabled templates for the relevant month and dates

### Requirement: Disabling does not remove paid fulfillments

Turning scheduling enabled to **false** MUST NOT delete or unlink existing **RecurringPaymentOccurrences** or **Expenses** that fulfilled a month. If a month was marked paid before disable, the expense MUST remain visible in Daily and Monthly expense views and the occurrence MUST still reference that expense.

#### Scenario: Paid then disabled keeps expense history

- **WHEN** a template was marked paid for a given month and the user later disables scheduling for that template
- **THEN** the linked expense for that month SHALL remain in storage and in expense lists, and the occurrence SHALL still record paid state for that month

### Requirement: Add or edit recurring template form respects the soft keyboard

The screen used to create or edit a recurring payment template MUST lay out correctly when the on-screen keyboard is visible. The implementation MUST NOT apply the keyboard’s bottom inset twice to the same subtree (for example, combining default `Scaffold` bottom resize with an additional full `MediaQuery.viewInsets.bottom` pad on the body). The form MUST remain scrollable so the user can reach title, amount, category, due date, end month (when shown), and save while the IME is open.

#### Scenario: No large dead band above keyboard

- **WHEN** the user focuses the template title or amount field on a device with the soft keyboard shown
- **THEN** the layout SHALL NOT reserve a second full keyboard-height empty band between the form content and the keyboard beyond what the framework’s single inset handling provides

#### Scenario: Form remains usable

- **WHEN** the soft keyboard is visible on the add or edit recurring template screen
- **THEN** the user SHALL be able to scroll to and interact with all primary controls (including save) without the keyboard permanently obscuring them with no way to scroll

