## MODIFIED Requirements

### Requirement: App provides bottom navigation for primary sections
The system MUST provide a bottom navigation shell that exposes the primary app sections as tabs:
- Home (Dashboard)
- Expenses
- Add (central action)
- Insights
- Settings

#### Scenario: User switches tabs
- **WHEN** the user taps a bottom navigation item
- **THEN** the shell SHALL switch the visible tab content to the selected section

#### Scenario: Add tab opens Add Expense
- **WHEN** the user taps the central “Add” tab
- **THEN** the shell SHALL display the Add Expense screen

