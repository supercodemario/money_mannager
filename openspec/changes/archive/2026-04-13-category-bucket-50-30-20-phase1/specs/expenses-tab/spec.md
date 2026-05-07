## ADDED Requirements

### Requirement: Expense classification uses selected category bucket
When the user records an expense by selecting a category, the system MUST derive and persist the expense’s 50/30/20 classification from that category’s assigned bucket without requiring separate bucket input.

#### Scenario: Category selection auto-classifies expense
- **WHEN** the user selects a category while adding an expense
- **THEN** the expense SHALL be classified under the category’s bucket (`needs`, `wants`, or `savings_debt`) automatically

#### Scenario: Bucket change affects future expense classification
- **WHEN** a category’s bucket assignment is updated
- **THEN** new expenses recorded with that category SHALL use the updated bucket assignment
