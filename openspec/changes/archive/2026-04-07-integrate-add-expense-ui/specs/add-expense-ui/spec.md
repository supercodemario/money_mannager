## ADDED Requirements

### Requirement: User can add an expense via a dedicated screen
The system MUST provide an “Add Expense” screen that allows the user to enter the details required to create an expense transaction.

#### Scenario: User opens Add Expense screen from bottom navigation
- **WHEN** the user selects the central “Add” tab from the bottom navigation
- **THEN** the app SHALL display the Add Expense screen

### Requirement: Amount entry is prominent and numeric
The Add Expense screen MUST provide a prominent amount entry control with a numeric keyboard.

#### Scenario: User types an amount
- **WHEN** the user focuses the amount field and enters digits (and an optional decimal)
- **THEN** the entered amount SHALL be visible in a large, high-emphasis style

### Requirement: User can set date and note
The Add Expense screen MUST provide inputs for:
- date (transaction date)
- note (free-form text)

#### Scenario: User edits date and note
- **WHEN** the user changes the date or enters a note
- **THEN** the screen SHALL reflect the chosen values

### Requirement: User can choose a category
The Add Expense screen MUST provide a category selector showing a grid of categories with iconography and labels.

#### Scenario: User selects a category
- **WHEN** the user taps a category in the grid
- **THEN** the tapped category SHALL become the selected category for the expense

### Requirement: Save and cancel actions exist
The Add Expense screen MUST provide:
- a primary action to save the expense
- a secondary action to cancel and dismiss the screen

#### Scenario: User cancels
- **WHEN** the user taps “Cancel”
- **THEN** the app SHALL exit the Add Expense screen without saving

### Requirement: Token-first UI and centralized strings
The Add Expense screen UI MUST use shared tokens for colors/spacing/radius/typography and MUST use centralized string tokens for visible labels.

#### Scenario: Screen uses tokens and AppStrings
- **WHEN** the Add Expense screen is rendered
- **THEN** it SHALL reference tokens under `lib/share/tokens/` and strings under `lib/share/tokens/app_strings.dart`

