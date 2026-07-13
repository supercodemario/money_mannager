## ADDED Requirements

### Requirement: Prefer locked Pace for day over/under when snapshot exists

For each day on or before the current local day, when a Pace snapshot exists for that local date, the listing MUST use that day’s locked `paceMinor` (when positive) as the threshold for over/under coloring of that day’s spent amount, instead of Daily plan. When no snapshot exists for that date, the listing MUST continue to use Daily plan as the threshold.

#### Scenario: Snapshot day uses Pace threshold

- **WHEN** a past or today row has locked Pace **500** and spent **600**
- **THEN** that day’s spent presentation SHALL use the over-plan (error) color relative to Pace

#### Scenario: Missing snapshot keeps Daily plan threshold

- **WHEN** a past or today row has no Pace snapshot and Daily plan is **100** and spent is **50**
- **THEN** that day’s spent presentation SHALL use the under-plan (positive) color relative to Daily plan
