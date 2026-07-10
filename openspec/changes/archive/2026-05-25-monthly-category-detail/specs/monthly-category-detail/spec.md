# monthly-category-detail Specification

## Purpose

Drill-down from Expenses **Monthly** category totals into per-category transaction detail and a within-month daily spending trend.

## ADDED Requirements

### Requirement: Monthly category row opens category detail

The system SHALL navigate to a **category detail** screen when the user taps a category total row in Expenses **Monthly** mode. The screen SHALL receive the selected **category id** and **calendar month** (year and month) from the parent Expenses context.

#### Scenario: User taps category from Monthly list

- **WHEN** the user taps a category row in Monthly mode that shows a non-zero or zero total for the selected month
- **THEN** the system SHALL open the category detail screen for that category and month

### Requirement: Category detail shows month stepper

The category detail screen SHALL include prev/next month navigation using the same **DateStepperPill** presentation as the Expenses tab (month icon, formatted month label, chevrons, accessible tooltips). Changing the month SHALL update both Transactions and Trend tab content.

#### Scenario: User changes month on detail screen

- **WHEN** the user activates previous or next on the month stepper on category detail
- **THEN** the selected calendar month SHALL change by one month and both tabs SHALL reload data for the new month

### Requirement: Category detail has Transactions and Trend tabs

The category detail screen SHALL provide two modes—**Transactions** and **Trend**—via a two-segment pill control consistent with the Expenses mode switcher pattern (sliding indicator, label contrast, no check icons on segments).

#### Scenario: User switches between Transactions and Trend

- **WHEN** the user selects Transactions or Trend on category detail
- **THEN** the screen SHALL show the corresponding content without leaving the screen

### Requirement: Transactions tab shows organized expense cards

In **Transactions** mode, the system SHALL list every expense in the selected **local calendar month** with the selected **category id**, ordered by **occurred-at** descending (most recent first). Each expense SHALL be presented in an **AppCard** with:

- A **primary line**: formatted amount on the start side and a **local calendar date** on the end side (date portion of occurred-at; time not required on the primary line).
- A **secondary line**: `Paid by · {display name}` where display name comes from the creator user profile join, with a defined fallback when the profile is missing.
- A **secondary line**: `Family · {household label}` resolved from `household_id` per household-name rules in this specification.
- An **optional tertiary line**: expense note text when the note is non-empty.

The list SHALL NOT repeat the category icon or category name on each row (category context is in the screen title).

#### Scenario: Transaction card shows paid-by and family

- **WHEN** the user views Transactions for a month that includes an expense in the selected category with a known creator and household
- **THEN** each card SHALL show amount, date, paid-by line, and family line as specified

#### Scenario: Note shown only when present

- **WHEN** an expense has a non-empty note
- **THEN** the card SHALL show the note below the family line

#### Scenario: Empty month shows empty state

- **WHEN** no expenses exist for the category in the selected month
- **THEN** Transactions SHALL show the same empty-state pattern used elsewhere on the Expenses tab

### Requirement: Family label on transaction cards

For each expense row, the **Family** line SHALL resolve `household_id` as follows:

- When `household_id` matches a household in the user’s loaded household list, the line SHALL show that household’s display name.
- When `household_id` is null, the line SHALL show a defined unset label from centralized string tokens.
- When `household_id` is non-null but not in the loaded list, the line SHALL show a defined unknown label from centralized string tokens.

#### Scenario: Shared household name shown

- **WHEN** the expense has a `household_id` for a shared household the user belongs to and the name is available from the household list
- **THEN** the Family line SHALL show that household name

#### Scenario: Null household shows unset label

- **WHEN** the expense has no `household_id`
- **THEN** the Family line SHALL show the unset label token

### Requirement: Trend tab shows daily category spend for selected month

In **Trend** mode, the system SHALL display a **line chart** of total spend (**amount_minor** sum) for the selected **category id** for each **local calendar day** in the selected month. Days with no expenses SHALL contribute **zero** to the series so the chart spans the full month. The chart SHALL use shared color/typography tokens where applicable.

#### Scenario: Chart reflects daily totals

- **WHEN** the user views Trend for a month where the category has expenses on two different days
- **THEN** the chart SHALL show two non-zero points on those days and zero (or baseline) on other days in that month

#### Scenario: Empty month trend

- **WHEN** the user views Trend for a month with no expenses in the category
- **THEN** the system SHALL show an appropriate empty or zero baseline presentation without error

### Requirement: Category detail data from local storage

Transactions and Trend MUST read expense data from the local Drift database via repository streams (not hardcoded samples). Creator display names MUST use the same join approach as Daily expense lists.

#### Scenario: New expense appears after save

- **WHEN** the user saves an expense in the selected category and month via Quick Add or equivalent
- **THEN** category detail SHALL update to include that expense without restarting the app

### Requirement: Category detail uses centralized strings and tokens

Visible labels on category detail (screen title segments, Paid by / Family prefixes, tab labels, tooltips) MUST use `AppStrings` (or equivalent centralized tokens). Layout and colors MUST use shared design tokens, not raw hex or ad-hoc spacing in feature views.

#### Scenario: Paid-by and family prefixes are tokenized

- **WHEN** category detail renders transaction cards
- **THEN** the Paid by and Family prefixes SHALL come from centralized string tokens
