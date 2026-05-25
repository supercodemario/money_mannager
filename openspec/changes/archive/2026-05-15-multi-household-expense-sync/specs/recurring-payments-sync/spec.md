# recurring-payments-sync (delta)

## MODIFIED Requirements

### Requirement: Recurring payment upload

The system SHALL upload pending recurring payment templates and occurrences to Supabase from the sync layer using idempotent upserts. Each template SHALL be sent with its stored `household_id` and `auth_user_id` equal to the signed-in user. Sync MUST NOT be limited to a single active household id per cycle.

#### Scenario: Pending recurring rows upload in dependency order

- **WHEN** sync runs with pending recurring templates, pending expenses, and pending recurring occurrences
- **THEN** the system SHALL upload recurring templates before expenses and recurring occurrences after expenses

#### Scenario: Recurring upload fails

- **WHEN** a recurring template or occurrence upload fails
- **THEN** the system SHALL keep the local row available and mark it error or otherwise retryable without losing the user's saved values

#### Scenario: Recurring push uses row household

- **WHEN** a pending recurring template is uploaded
- **THEN** the remote row SHALL include the template's local `household_id` and the writer's `auth_user_id`

### Requirement: Recurring payment download

The system SHALL pull recurring payment templates and occurrences from Supabase during sync and merge them into local Drift storage for **all** households the user belongs to (RLS-scoped incremental pull without a single-household client filter).

#### Scenario: Remote recurring rows hydrate local storage

- **WHEN** a signed-in user runs post-login bootstrap or manual refresh and Supabase contains recurring payment data for any member household
- **THEN** the system SHALL merge templates and occurrences into local storage so recurring screens restore template and paid-month state

#### Scenario: Pull preserves dependency order

- **WHEN** recurring data and expenses are pulled from Supabase
- **THEN** the system SHALL merge recurring templates before expenses and recurring occurrences after expenses

#### Scenario: Recurring pull spans all member households

- **WHEN** the user is a member of multiple households and recurring sync runs
- **THEN** the client SHALL merge recurring templates and occurrences from all member households into local storage
