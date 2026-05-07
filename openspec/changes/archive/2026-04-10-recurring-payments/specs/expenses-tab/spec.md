## MODIFIED Requirements

### Requirement: Expenses tab shows Daily, Monthly, and Recurring switches

The system MUST provide an Expenses tab screen that allows the user to switch between **Daily**, **Monthly**, and **Recurring payments** views of expense-related information.

#### Scenario: User switches view mode

- **WHEN** the user selects Daily, Monthly, or Recurring payments in the Expenses tab
- **THEN** the Expenses tab SHALL update to show the corresponding view

## ADDED Requirements

### Requirement: Recurring payments view lists monthly recurring items with paid state

When **Recurring payments** mode is selected, the system MUST show recurring payment obligations for the **selected calendar month** (with navigation consistent with Monthly mode where applicable), including each item’s title, category, due state (paid vs unpaid), overdue indication when applicable, and **mark as paid** for unpaid items.

#### Scenario: Recurring mode is distinct from Daily and Monthly

- **WHEN** the user selects Recurring payments
- **THEN** the screen SHALL NOT show only the Daily grouped-by-day expense list or the Monthly category totals list; it SHALL show the recurring payments list
