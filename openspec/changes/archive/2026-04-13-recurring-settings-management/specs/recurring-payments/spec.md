## ADDED Requirements

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

## MODIFIED Requirements

### Requirement: Home dashboard and Expenses Recurring use the same data

The home dashboard MUST NOT use static placeholder bill data. Upcoming and overdue sections MUST read the same persisted recurring occurrence data as the Expenses tab **Recurring payments** mode, **limited to templates whose scheduling enabled flag is true**. Templates with scheduling disabled MUST NOT contribute rows to those sections. The home view MUST present **two labeled sections** (e.g. **Overdue** and **Upcoming**) for unpaid items so users can scan quickly at a glance.

#### Scenario: Consistency across surfaces

- **WHEN** the user marks a recurring payment as paid from either the home dashboard or the Expenses Recurring view
- **THEN** both surfaces SHALL reflect the updated paid state without contradictory rows

#### Scenario: Disabled template omitted from both surfaces

- **WHEN** a template has scheduling disabled
- **THEN** it SHALL NOT appear in the home dashboard overdue or upcoming sections nor in the Expenses tab Recurring payments list until scheduling is enabled again

### Requirement: Recurring list shows paid and unpaid

The Expenses **Recurring payments** view MUST list recurring items for the selected month **for templates with scheduling enabled only**, with a clear **paid** or **unpaid** state. Paid items MUST remain visible in that list (not only in Daily/Monthly expense lists).

#### Scenario: Paid visible in recurring list

- **WHEN** a recurring payment has been marked paid for the selected month and its template has scheduling enabled
- **THEN** the Recurring payments list SHALL show it as paid while the corresponding expense appears in Daily and Monthly views
