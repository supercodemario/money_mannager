# expense-auto-push-sync Specification

## Purpose
TBD - created by archiving change expense-auto-push-connectivity. Update Purpose after archive.
## Requirements
### Requirement: Automatic expense sync uploads pending rows without pull

When the automatic expense sync cycle runs, the system SHALL upload only local expense rows with sync status `pending` and SHALL NOT perform any remote pull in that cycle.

#### Scenario: Auto cycle completes upload only

- **WHEN** the automatic expense sync cycle runs successfully for one or more pending expenses
- **THEN** those expenses SHALL be upserted to Supabase and marked `synced` locally
- **AND** the cycle SHALL NOT fetch or merge remote expense rows in the same cycle

### Requirement: Automatic expense sync requires session and OS connectivity

The automatic expense sync cycle SHALL run only when cloud sync is allowed for the current session and the operating system reports network connectivity.

#### Scenario: Logged in and OS online

- **WHEN** cloud sync is allowed and OS connectivity indicates the device is online
- **AND** one or more expenses are `pending`
- **THEN** the system SHALL attempt to upsert those expenses to Supabase

#### Scenario: OS offline skips upload

- **WHEN** cloud sync is allowed but OS connectivity indicates the device is offline
- **AND** one or more expenses are `pending`
- **THEN** the system SHALL NOT attempt Supabase upsert for those expenses in that cycle
- **AND** those expenses SHALL remain `pending`

#### Scenario: Not logged in skips auto upload

- **WHEN** no authenticated cloud session exists
- **THEN** the automatic expense sync cycle SHALL NOT upload expenses

### Requirement: Offline auto sync does not mark expenses as error

When the automatic expense sync cycle is skipped solely because OS connectivity is unavailable, the system MUST NOT change expense sync status from `pending` to `error`.

#### Scenario: Pending preserved while offline

- **WHEN** expenses are `pending` and the automatic cycle is skipped due to OS offline state
- **THEN** those expenses SHALL remain `pending`

### Requirement: Automatic expense sync retries on connectivity restoration

When OS connectivity transitions from offline to online and cloud sync is allowed, the system SHALL schedule an automatic expense sync cycle so pending expenses can upload without user action.

#### Scenario: Reconnect triggers upload

- **WHEN** OS connectivity becomes available after being unavailable
- **AND** cloud sync is allowed
- **AND** pending expenses exist
- **THEN** the system SHALL run the automatic expense sync cycle and attempt upload

### Requirement: New pending expenses trigger automatic upload attempt

When a logged-in user saves an expense that is stored with sync status `pending`, the system SHALL schedule the automatic expense sync cycle subject to OS connectivity and session rules.

#### Scenario: Save while online schedules push

- **WHEN** a user saves a new expense while cloud sync is allowed and OS connectivity is available
- **THEN** the expense SHALL be stored as `pending` locally
- **AND** the system SHALL schedule automatic expense sync that attempts Supabase upsert without pull

#### Scenario: Save while offline stays pending

- **WHEN** a user saves a new expense while cloud sync is allowed but OS connectivity is unavailable
- **THEN** the expense SHALL be stored as `pending` locally
- **AND** the system SHALL NOT mark the expense `synced` or `error` until a successful upload occurs

