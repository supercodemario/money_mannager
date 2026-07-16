## ADDED Requirements

### Requirement: Quick Add accepts optional prefill
The Quick Add (regular New Expense) screen MUST accept optional initial values for amount, note, and date. When an initial amount is provided, those fields MUST be shown pre-populated and the screen MAY open on the category phase so the user can select a category and save. The user MUST still be able to edit amount and note before saving.

#### Scenario: Open with prefilled amount and note from Payment SMS
- **WHEN** Quick Add is opened with an initial amount and note
- **THEN** the amount and note SHALL display those values
- **AND** the user SHALL still choose a category before a successful save

#### Scenario: Prefill date when provided
- **WHEN** Quick Add is opened with an initial date
- **THEN** the date control SHALL show that date

#### Scenario: Open without prefill unchanged
- **WHEN** Quick Add is opened without initial values
- **THEN** the screen SHALL behave as before (amount phase first, empty note, date defaulting per existing behavior)
