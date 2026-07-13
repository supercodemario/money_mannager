# recurring-payments-sync Specification

## Purpose

Define phase-1 sync behavior for recurring payment templates and occurrences, including household-scoped cloud storage, local-first eligibility, ordered upload/download, and deterministic conflict and dependency handling.
## Requirements
### Requirement: Household-scoped recurring payment storage

The system SHALL store synced recurring payment templates and recurring payment occurrences in Supabase scoped to the household, using household membership authorization consistent with synced expenses.

#### Scenario: Household member reads recurring rows

- **WHEN** an authenticated household member reads recurring payment templates or occurrences from Supabase
- **THEN** the system SHALL return rows belonging to that member's household

#### Scenario: Non-member cannot read recurring rows

- **WHEN** an authenticated user reads recurring payment templates or occurrences for a household they do not belong to
- **THEN** the system SHALL NOT return those rows

### Requirement: Local recurring changes are sync eligible

The system SHALL mark recurring payment template and occurrence creates, updates, scheduling toggles, paid-state changes, and supported delete/tombstone operations as sync eligible using local-first sync state.

#### Scenario: Save recurring data while signed in

- **WHEN** the user changes a recurring template or occurrence while Supabase sync is allowed
- **THEN** the system SHALL persist the change locally and mark it pending upload

#### Scenario: Save recurring data while signed out

- **WHEN** the user changes a recurring template or occurrence without an authenticated Supabase session
- **THEN** the system SHALL persist the change locally and keep it local-only until the user explicitly starts authenticated sync

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

### Requirement: Recurring payment conflicts use last-write-wins

The system SHALL resolve recurring template and occurrence conflicts by comparing `updated_at` and applying the newer version.

#### Scenario: Remote recurring row is newer

- **WHEN** a pulled remote recurring template or occurrence has `updated_at` greater than the matching local row
- **THEN** the system SHALL update local row fields and sync metadata from the remote row

#### Scenario: Local recurring row is newer

- **WHEN** a pulled remote recurring template or occurrence has `updated_at` older than the matching local row
- **THEN** the system SHALL keep the local row values and preserve their sync eligibility

### Requirement: Missing recurring dependencies are handled safely

The system SHALL avoid crashes when a pulled recurring occurrence references a missing recurring template or expense.

#### Scenario: Occurrence references missing dependency

- **WHEN** a pulled recurring occurrence references a template or expense that is not present locally after the dependency pull stages
- **THEN** the system SHALL skip, defer, or mark the occurrence retryable according to the implementation's documented strategy without losing other synced rows

