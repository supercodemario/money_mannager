## ADDED Requirements

### Requirement: Persist immutable Pace per local day

The system MUST persist at most one Pace snapshot per active user (and the same expense scope used for month spent) for each local calendar date. When a snapshot is first created for a date, the system MUST store at least: local date key, `paceMinor`, spendable pool at write time, spent-before-today minor at write time, days-after-today at write time, and created-at. Once stored, `paceMinor` and those snapshot inputs MUST NOT be updated for that date key.

#### Scenario: First ensure creates row

- **WHEN** limits are configured and no snapshot exists for the current local date
- **THEN** the system SHALL insert a Pace snapshot for that date

#### Scenario: Second ensure is a no-op

- **WHEN** a Pace snapshot already exists for the current local date
- **AND** the ensure path runs again (including after new expenses today)
- **THEN** the system SHALL NOT change that row’s `paceMinor` or snapshot input fields

### Requirement: Snapshot formula excludes today from spent and from day count

When creating a Pace snapshot for local date with **D** days in the month, the system MUST compute:

- `spentBeforeToday` = sum of expenses in the active scope with local dates strictly before today in the current month (or equivalent range that excludes today)
- `daysAfterToday` = `D − dayOfMonth` (excluding today)
- `paceMinor` = `max(0, pool − spentBeforeToday) ~/ daysAfterToday` when `daysAfterToday > 0` and that remaining is positive; otherwise `paceMinor` MUST be **zero**

#### Scenario: Today’s spend does not enter snapshot math

- **WHEN** the snapshot is created and expenses already exist dated today
- **THEN** those today’s amounts MUST NOT be included in `spentBeforeToday` used for `paceMinor`

#### Scenario: Divisor excludes today

- **WHEN** the month has 30 days and local day-of-month is **10**
- **THEN** `daysAfterToday` stored on the snapshot MUST be **20**

### Requirement: History readable for analytics

The system MUST allow reading Pace snapshots by user for a local date range (at least the current month) so future analytics and graphs can plot Pace over days without recomputing from current preferences.

#### Scenario: Month query returns stored days

- **WHEN** snapshots exist for some days in the current month
- **AND** a range query for that month is performed
- **THEN** the system SHALL return those stored rows with their locked `paceMinor` values
