# month-day-spend-listing Specification

## Purpose

Users can open a current-month day listing from Home to compare **Daily plan** with actual spend per day, including over/under coloring for days through today.

## Requirements

### Requirement: Month day spend listing shows plan vs spent

The system MUST provide a listing screen for the **current local calendar month** that includes one row per day from 1 through **D** (days in that month). Each row MUST show that day’s **Daily plan** (same `pool ~/ D` as Home) and the **actual amount spent** that local day (sum of expenses dated that day in the active expense scope). Days with no expenses MUST show spent as zero (or an explicit zero equivalent).

#### Scenario: All month days listed

- **WHEN** the user opens the month day spend listing for a 30-day month
- **THEN** the list SHALL contain exactly 30 day rows

#### Scenario: Spent aggregates local day expenses

- **WHEN** two expenses on the same local calendar day total 500 minor units
- **THEN** that day’s spent amount SHALL be 500 minor units

### Requirement: Over/under coloring for days through today

For each day on or before the current local day, when Daily plan is positive, the system MUST style spent **greater than** Daily plan using the error/over-budget color treatment, and spent **less than or equal to** Daily plan using a positive/under-plan color treatment (e.g. secondary/green). Future days (after today) MUST use neutral/muted styling for spent when presenting zero or placeholder spent, and MUST NOT use the under-plan success color solely because spent is zero.

#### Scenario: Over plan is red

- **WHEN** Daily plan is 100 and spent on a past or today row is 200
- **THEN** that day’s spent presentation SHALL use the over-plan (error) color

#### Scenario: Under or equal plan is green

- **WHEN** Daily plan is 100 and spent on a past or today row is 100 or less
- **THEN** that day’s spent presentation SHALL use the under-plan (positive) color

#### Scenario: Future day stays neutral at zero spent

- **WHEN** a row is a future day in the current month with zero spent
- **THEN** that row SHALL NOT use the under-plan success color for spent

### Requirement: Listing reachable from Home dual daily

The month day spend listing MUST be reachable by tapping the Home Daily plan / Pace / day row when limits are configured.

#### Scenario: Navigation from Home

- **WHEN** limits are configured and the user taps Daily plan / Pace / day on Home
- **THEN** the month day spend listing SHALL be displayed
