## ADDED Requirements

### Requirement: Recurring auto push uploads pending rows without pull

When the recurring auto-push path runs, the system SHALL upload pending recurring templates, then pending expenses, then pending recurring occurrences, and SHALL NOT perform remote pull in that path.

#### Scenario: Ordered upload completes without pull

- **WHEN** the recurring auto-push path runs successfully with pending templates, expenses, and occurrences
- **THEN** templates SHALL be upserted before expenses and occurrences after expenses
- **AND** the path SHALL NOT fetch or merge remote recurring or expense rows in the same path

### Requirement: Recurring auto push requires session and OS connectivity

The recurring auto-push path SHALL run only when cloud sync is allowed for the current session and the operating system reports network connectivity.

#### Scenario: Logged in and OS online

- **WHEN** cloud sync is allowed and OS connectivity indicates the device is online
- **AND** one or more recurring templates or occurrences are `pending`
- **THEN** the system SHALL attempt ordered upload to Supabase

#### Scenario: OS offline skips upload

- **WHEN** cloud sync is allowed but OS connectivity indicates the device is offline
- **AND** recurring rows are `pending`
- **THEN** the system SHALL NOT attempt Supabase upsert for those rows in that path
- **AND** those rows SHALL remain `pending`

#### Scenario: Not logged in skips auto upload

- **WHEN** no authenticated cloud session exists
- **THEN** the recurring auto-push path SHALL NOT upload recurring rows

### Requirement: Offline recurring auto push does not mark error

When the recurring auto-push path is skipped solely because OS connectivity is unavailable, the system MUST NOT change recurring sync status from `pending` to `error`.

#### Scenario: Pending preserved while offline

- **WHEN** recurring rows are `pending` and the path is skipped due to OS offline state
- **THEN** those rows SHALL remain `pending`

### Requirement: Recurring mutations schedule auto push

When a logged-in user creates, updates, toggles, deletes, or marks paid a recurring payment such that local rows become `pending`, the system SHALL run the recurring auto-push path subject to OS connectivity and session rules.

#### Scenario: Save template while online schedules push

- **WHEN** a user saves a new or updated recurring template while cloud sync is allowed and OS connectivity is available
- **THEN** the template SHALL be stored as `pending` locally
- **AND** the system SHALL attempt Supabase upsert for pending recurring work without pull

#### Scenario: Mark paid while online pushes expense and occurrence

- **WHEN** a user marks a recurring payment paid for a month while cloud sync is allowed and OS connectivity is available
- **THEN** the system SHALL upload the related pending expense and occurrence in dependency order after any pending templates

#### Scenario: Save while offline stays pending

- **WHEN** a user changes recurring data while cloud sync is allowed but OS connectivity is unavailable
- **THEN** affected rows SHALL remain `pending` locally
- **AND** the system SHALL NOT mark them `synced` or `error` until a successful upload occurs

### Requirement: Automatic expense cycle also drains pending recurring

When the automatic expense sync cycle runs, the system SHALL also run the recurring auto-push path (ordered templates → expenses → occurrences) so stranded pending recurring rows upload without opening manual sync UI.

#### Scenario: Auto cycle uploads pending templates

- **WHEN** the automatic expense sync cycle runs while cloud sync is allowed and the device is online
- **AND** pending recurring templates exist
- **THEN** those templates SHALL be uploaded as part of that cycle’s recurring auto-push path
