# supabase-phase1-sync (delta)

## ADDED Requirements

### Requirement: Background sync uses automatic expense push only

When the sync orchestrator reacts to local database pending state or session changes outside an explicit user-initiated manual sync, it SHALL run the automatic expense push cycle (expenses only, no pull) rather than a full push-then-pull cycle for all entity types.

#### Scenario: Pending expense watch triggers auto push

- **WHEN** a new or updated expense row becomes `pending` and the orchestrator schedules a background cycle
- **THEN** the orchestrator SHALL invoke automatic expense push only
- **AND** SHALL NOT pull remote entities in that background cycle

#### Scenario: Manual sync remains full cycle

- **WHEN** the user or app invokes explicit manual sync (for example settings sync, post-login sync, or logout preflight)
- **THEN** the orchestrator SHALL run full push-then-pull for all phase-1 in-scope entities per existing requirements

## MODIFIED Requirements

### Requirement: Phase-1 incremental sync contract

The system MUST synchronize application domain entities between local storage and Supabase using incremental semantics (for example timestamps or version fields), not full-table replacement on each sync, for the entities in scope of this change.

#### Scenario: Push local changes

- **WHEN** local entities are marked pending upload and connectivity and session allow sync
- **THEN** the system SHALL upsert those entities to Supabase with idempotent identifiers where specified by design

#### Scenario: Pull remote changes

- **WHEN** a sync pull runs after a recorded cursor or since a known watermark
- **THEN** the system SHALL merge remote changes into local storage per the documented conflict strategy for phase 1

#### Scenario: Automatic expense push does not pull

- **WHEN** the automatic expense sync cycle runs for pending expenses
- **THEN** the system SHALL upsert those pending expenses when session and OS connectivity allow
- **AND** SHALL NOT perform a remote pull in that same automatic cycle

### Requirement: Presentation layer does not call remote APIs for domain sync

User interface and feature modules MUST NOT invoke the network layer or Supabase client directly to upload, download, or reconcile domain entity data. Domain persistence MUST go through repositories that write to local storage; remote synchronization for those entities MUST be driven by a component that reacts to local database state (for example pending sync flags or an outbox), not by UI event handlers calling remote APIs.

#### Scenario: Screen saves expense locally only

- **WHEN** the user saves an expense from a screen
- **THEN** the screen's code path SHALL persist through local repositories or equivalent domain APIs only and MUST NOT invoke Supabase or the remote sync implementation directly for that save

#### Scenario: Screen saves expense profile locally only

- **WHEN** the user saves expense profile preferences from the expense limits screen
- **THEN** the screen's code path SHALL persist through local repositories or equivalent domain APIs only and MUST NOT invoke Supabase or the remote sync implementation directly for that save

#### Scenario: Screen saves recurring data locally only

- **WHEN** the user creates, updates, disables, deletes, or marks paid a recurring payment from a screen
- **THEN** the screen's code path SHALL persist through local repositories or equivalent domain APIs only and MUST NOT invoke Supabase or the remote sync implementation directly for that save

#### Scenario: Remote entity sync runs from orchestrator

- **WHEN** local rows are eligible for upload or a scheduled sync cycle runs
- **THEN** the system SHALL perform Supabase-backed entity operations only from the documented sync or remote orchestration layer based on persisted pending state, not from feature UI code

#### Scenario: Background expense upload uses auto push path

- **WHEN** local expense rows become `pending` and the orchestrator schedules background work
- **THEN** expense upload SHALL be performed only through the automatic expense push orchestration path
- **AND** feature UI code SHALL NOT invoke Supabase for that upload

### Requirement: Expense and recurring sync uses all member households

The sync orchestration layer SHALL pull household-scoped entities (expenses, recurring templates, recurring occurrences) for **every** household the authenticated user belongs to in a single incremental sync cycle. The client SHALL NOT restrict pull queries to a single active `household_id`. Row Level Security SHALL remain the authority for which rows are visible.

#### Scenario: User in multiple families receives merged pull

- **WHEN** an authenticated user is a member of more than one household and runs **manual** sync
- **THEN** the client SHALL pull remote rows from all those households (including expenses created by other members) subject to RLS

#### Scenario: Push sends per-row household

- **WHEN** the client uploads a pending local expense or recurring row
- **THEN** the upsert SHALL include that row’s stored `household_id` and `auth_user_id` equal to the signed-in user

#### Scenario: Pull does not require resolved sync household id

- **WHEN** manual sync runs and the user has at least one household membership
- **THEN** sync SHALL proceed without requiring a persisted single-household sync scope key

#### Scenario: Automatic expense push does not pull households

- **WHEN** the automatic expense sync cycle runs
- **THEN** the client SHALL NOT perform a household-scoped pull in that cycle
