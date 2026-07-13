## MODIFIED Requirements

### Requirement: Recurring payment upload

The system SHALL upload pending recurring payment templates and occurrences to Supabase from the sync layer using idempotent upserts. Each template SHALL be sent with its stored `household_id` and `auth_user_id` equal to the signed-in user. Sync MUST NOT be limited to a single active household id per cycle. Upload MAY run from full manual sync **or** from the recurring auto-push path (on mutation / automatic cycle) without pull.

#### Scenario: Pending recurring rows upload in dependency order

- **WHEN** sync runs with pending recurring templates, pending expenses, and pending recurring occurrences
- **THEN** the system SHALL upload recurring templates before expenses and recurring occurrences after expenses

#### Scenario: Recurring upload fails

- **WHEN** a recurring template or occurrence upload fails
- **THEN** the system SHALL keep the local row available and mark it error or otherwise retryable without losing the user's saved values

#### Scenario: Recurring push uses row household

- **WHEN** a pending recurring template is uploaded
- **THEN** the remote row SHALL include the template's local `household_id` and the writer's `auth_user_id`

#### Scenario: Auto-push path uploads without opening manual sync UI

- **WHEN** pending recurring rows exist and the recurring auto-push path runs while the user is signed in and online
- **THEN** the system SHALL upload those pending rows using the same dependency order as manual sync
- **AND** the user SHALL NOT be required to open the Recurring cloud sync screen for that upload to occur
