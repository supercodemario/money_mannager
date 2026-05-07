# quick-add-two-phase Specification

## Purpose

TBD - created by archiving change quick-add-amount-then-category. Update Purpose after archive.

## Requirements

### Requirement: Quick Add separates amount entry from category selection

The Quick Add screen MUST present two distinct interaction modes: an **amount entry** mode and a **category selection** mode. In amount entry mode, the category grid MUST NOT be shown. In category selection mode, the numeric keypad MUST NOT be shown.

#### Scenario: Amount mode hides categories

- **WHEN** Quick Add is in amount entry mode
- **THEN** the category selector grid SHALL NOT be visible

#### Scenario: Category mode hides keypad

- **WHEN** Quick Add is in category selection mode
- **THEN** the custom numeric keypad SHALL NOT be visible

### Requirement: Positive amount is required before category selection

The system MUST NOT allow the user to enter category selection mode unless the entered amount is strictly greater than zero.

#### Scenario: Blocked at zero

- **WHEN** the displayed amount is `0.00` (or equivalent zero)
- **THEN** the control that advances to category selection SHALL be disabled or SHALL not complete the transition

#### Scenario: Allowed when positive

- **WHEN** the entered amount is greater than zero
- **THEN** the user SHALL be able to enter category selection mode

### Requirement: Returning to amount entry clears category

When the user returns from category selection mode to amount entry mode, the system MUST clear any previously selected expense category for that Quick Add session.

#### Scenario: Re-edit amount clears category

- **WHEN** the user returns to amount entry mode after having selected a category
- **THEN** no category SHALL remain selected until the user selects one again in category mode

### Requirement: Date and note remain available in both modes

The Quick Add screen MUST show the date control and the note field in both amount entry mode and category selection mode.

#### Scenario: Note visible in amount mode

- **WHEN** Quick Add is in amount entry mode
- **THEN** the note input SHALL be visible

#### Scenario: Note visible in category mode

- **WHEN** Quick Add is in category selection mode
- **THEN** the note input SHALL be visible

### Requirement: Instant-save hint only in category mode

Any instructional copy that describes saving by tapping a category (e.g. “Tap category to save instantly”) MUST be visible only while the screen is in category selection mode.

#### Scenario: Hint hidden in amount mode

- **WHEN** Quick Add is in amount entry mode
- **THEN** that instructional copy SHALL NOT be visible

#### Scenario: Hint visible in category mode

- **WHEN** Quick Add is in category selection mode
- **THEN** that instructional copy MAY be visible

### Requirement: Token-first Quick Add styling

Quick Add mode-specific layouts MUST continue to use shared design tokens for colors, spacing, and radii in feature UI code (no ad-hoc hex colors or raw pixel constants introduced for this change).

#### Scenario: Uses tokens

- **WHEN** Quick Add renders in either mode
- **THEN** new or adjusted visuals SHALL derive from shared tokens under `lib/share/tokens/`
