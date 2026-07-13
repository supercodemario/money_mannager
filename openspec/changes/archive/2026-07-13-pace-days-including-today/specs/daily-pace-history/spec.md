## MODIFIED Requirements

### Requirement: Snapshot formula excludes today from spent and from day count

When creating a Pace snapshot for a local date with **D** days in the month, the system MUST compute:

- `spentBeforeToday` = sum of expenses in the active scope with local dates strictly before today in the current month
- `daysLeftIncludingToday` = `D − dayOfMonth + 1` (today through end of month, minimum 0)
- `paceMinor` = `max(0, pool − spentBeforeToday) ~/ daysLeftIncludingToday` when `daysLeftIncludingToday > 0` and that remaining is positive; otherwise `paceMinor` MUST be **zero**

The snapshot MUST still exclude today’s expenses from `spentBeforeToday`. The divisor MUST **include** today.

#### Scenario: Today’s spend does not enter snapshot math

- **WHEN** the snapshot is created and expenses already exist dated today
- **THEN** those today’s amounts MUST NOT be included in `spentBeforeToday` used for `paceMinor`

#### Scenario: Divisor includes today

- **WHEN** the month has 30 days and local day-of-month is **10**
- **THEN** `daysLeftIncludingToday` stored/used for the snapshot MUST be **21**

#### Scenario: Last day uses divisor one

- **WHEN** local day-of-month equals **D** and leftover before today is positive
- **THEN** `daysLeftIncludingToday` MUST be **1**
- **AND** `paceMinor` MUST equal that leftover (integer division by 1)

## ADDED Requirements

### Requirement: Persist immutable Pace per local day

The system MUST persist at most one Pace snapshot per active user for each local calendar date. Once stored, `paceMinor` and snapshot inputs MUST NOT be updated for that date key. (Unchanged behavior from locked-daily-pace; retained for capability completeness.)

#### Scenario: Second ensure is a no-op

- **WHEN** a Pace snapshot already exists for the current local date
- **AND** the ensure path runs again
- **THEN** the system SHALL NOT change that row’s `paceMinor`
