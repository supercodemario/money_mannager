# supabase-phase1-sync Specification

## Purpose

Phase-1 cloud sync using Supabase: client bootstrap, auth-gated remote access, household-scoped RLS, incremental sync, conflict rules, local-first behavior, and repository/orchestrator boundaries so the presentation layer does not call remote sync APIs directly.

## Requirements

### Requirement: Supabase client initialization

The system MUST initialize the Supabase Flutter client when the application starts, using configuration supplied at build or runtime (for example environment-backed URL and anon key), without embedding secrets in source control.

#### Scenario: Client uses configured endpoints

- **WHEN** the application boots with valid Supabase configuration
- **THEN** the system SHALL complete singleton initialization such that authenticated and database APIs are available to the application layer

#### Scenario: Missing configuration fails safely

- **WHEN** Supabase configuration is absent or invalid at startup
- **THEN** the system SHALL not expose uninitialized Supabase APIs as usable for sync and SHALL surface a controlled failure path documented in implementation (for example feature disabled or error screen)

### Requirement: Authenticated session for sync

The system MUST support Supabase Auth sessions such that only users with a valid session MAY perform cloud-backed read and write operations subject to Row Level Security policies.

#### Scenario: Signed-in user can invoke sync APIs

- **WHEN** a user completes a successful Supabase Auth sign-in
- **THEN** the system SHALL associate subsequent remote operations with that session

#### Scenario: Signed-out user does not perform authenticated cloud sync

- **WHEN** no user session exists
- **THEN** the system SHALL NOT perform authenticated Supabase data mutations except as defined for anonymous flows in implementation (if any), and local-only mode MUST remain functional

### Requirement: Household-scoped authorization in PostgreSQL

The system MUST model multi-member access using PostgreSQL Row Level Security such that rows belonging to a household are only visible to authenticated members authorized for that household.

#### Scenario: Member reads household data

- **WHEN** an authenticated user requests rows scoped to a household of which they are a member
- **THEN** the system SHALL return only data permitted by RLS policies for that user

#### Scenario: Non-member cannot read other households

- **WHEN** an authenticated user requests data for a household of which they are not a member
- **THEN** the system SHALL deny read access consistent with RLS (zero rows or policy error as implemented)

### Requirement: Phase-1 incremental sync contract

The system MUST synchronize application domain entities between local storage and Supabase using incremental semantics (for example timestamps or version fields), not full-table replacement on each sync, for the entities in scope of this change.

#### Scenario: Push local changes

- **WHEN** local entities are marked pending upload and connectivity and session allow sync
- **THEN** the system SHALL upsert those entities to Supabase with idempotent identifiers where specified by design

#### Scenario: Pull remote changes

- **WHEN** a sync pull runs after a recorded cursor or since a known watermark
- **THEN** the system SHALL merge remote changes into local storage per the documented conflict strategy for phase 1

### Requirement: Conflict handling for phase 1

The system MUST apply a single documented conflict resolution strategy for concurrent updates to the same logical row during phase 1 (for example last-write-wins by server-observed update time) and MUST NOT silently drop updates without applying that strategy.

#### Scenario: Conflicts resolve by declared rule

- **WHEN** a conflict is detected between local and remote versions of the same row during sync
- **THEN** the system SHALL resolve the conflict according to the phase-1 rule stated in design and MUST preserve observability for debugging (for example logging or sync status on the entity)

### Requirement: Local-first availability

The system MUST allow recording and viewing data that remains eligible for local-only operation when cloud sync is unavailable, signed out, or disabled by configuration.

#### Scenario: Offline local capture

- **WHEN** the device cannot reach Supabase or the user is not signed in
- **THEN** the system SHALL still persist eligible operations to local storage per product rules

### Requirement: Unsigned local captures are marked local-only

When no authenticated Supabase session exists, newly saved sync-eligible entities MUST remain in local storage and MUST be marked with sync status `local_only` until the user explicitly chooses to sync after authentication.

#### Scenario: Create expense while signed out

- **WHEN** the user creates a new expense while not logged in
- **THEN** the expense SHALL be stored locally with sync status `local_only` and SHALL NOT be uploaded to Supabase

### Requirement: Login/signup prompts for local-only data sync

After a successful login or signup, if local-only expense rows exist, the app MUST present a dedicated **post-login cloud sync** screen before returning the user to the rest of the app. That screen MUST show the count of local-only expenses eligible for this flow (the same count used to decide that the screen is shown). The screen MUST offer an explicit primary control to **start sync** and an explicit control to **defer sync** without uploading. When the user starts sync, the app MUST show visible progress for the orchestrated stages **preparing** local data for upload, **uploading** local changes, and **downloading** latest cloud data, consistent with manual sync stage reporting used elsewhere in the app. When sync completes successfully, the screen MUST show a **completion** state and an explicit control to dismiss the flow. When sync fails, the screen MUST show the error reason and offer **Retry** (re-run the same sync path) and **defer** without signing out.

When the user completes sync from this flow, the app MUST promote eligible local-only rows to uploadable state, perform sync push then pull, and keep the user signed in. When the user defers from this flow, the app MUST keep those rows in `local_only` state and MUST NOT upload them in that flow.

#### Scenario: User starts sync from post-login screen

- **WHEN** login or signup succeeds and local-only expense rows are present and the user opens the post-login cloud sync screen and chooses to start sync
- **THEN** the app SHALL promote eligible local-only rows to uploadable state, perform sync push then pull, and keep the user signed in

#### Scenario: User defers sync from post-login screen

- **WHEN** login or signup succeeds and local-only expense rows are present and the user chooses to defer sync from the post-login cloud sync screen
- **THEN** the app SHALL keep those rows in `local_only` state and SHALL NOT upload them in that flow

#### Scenario: Post-login sync shows eligible count

- **WHEN** the post-login cloud sync screen is shown after authentication
- **THEN** the user SHALL see the number of expenses currently in `local_only` sync status that are eligible for upload in this flow

#### Scenario: Post-login sync shows stage progress

- **WHEN** the user has started sync from the post-login cloud sync screen
- **THEN** the user SHALL see progress feedback aligned to preparing, uploading, and downloading stages until the sync completes or fails

#### Scenario: Post-login sync completes

- **WHEN** sync started from the post-login cloud sync screen finishes without error
- **THEN** the app SHALL show a completion state and SHALL allow the user to dismiss the screen explicitly

#### Scenario: Post-login sync fails and user retries

- **WHEN** sync started from the post-login cloud sync screen fails and the user selects **Retry**
- **THEN** the app SHALL attempt the same sync path again and update progress and error state accordingly

#### Scenario: No local-only rows after auth

- **WHEN** login or signup succeeds and no local-only expense rows exist
- **THEN** the app SHALL NOT require the post-login cloud sync screen for that condition and SHALL follow the existing navigation behavior for closing or continuing the auth flow

### Requirement: Logout with unsynced data uses guarded sync screen

If the user requests logout while unsynced rows exist, the app MUST show a dedicated sync progress screen before logout. On failure, the screen MUST show error reason and provide `Retry` and `Logout without sync` actions.

#### Scenario: Logout sync succeeds

- **WHEN** logout is requested and unsynced rows exist and pre-logout sync succeeds
- **THEN** the app SHALL complete logout and wipe local database as defined by product rules

#### Scenario: Logout sync fails and user retries

- **WHEN** pre-logout sync fails and the user taps `Retry`
- **THEN** the app SHALL attempt the sync flow again and update progress/error state accordingly

#### Scenario: Logout without sync

- **WHEN** pre-logout sync fails and the user taps `Logout without sync`
- **THEN** the app SHALL complete logout, wipe local database, and MAY lose unsynced local-only or pending rows

### Requirement: Presentation layer does not call remote APIs for domain sync

User interface and feature modules MUST NOT invoke the network layer or Supabase client directly to upload, download, or reconcile domain entity data. Domain persistence MUST go through repositories that write to local storage; remote synchronization for those entities MUST be driven by a component that reacts to local database state (for example pending sync flags or an outbox), not by UI event handlers calling remote APIs.

#### Scenario: Screen saves expense locally only

- **WHEN** the user saves an expense from a screen
- **THEN** the screen’s code path SHALL persist through local repositories or equivalent domain APIs only and MUST NOT invoke Supabase or the remote sync implementation directly for that save

#### Scenario: Remote entity sync runs from orchestrator

- **WHEN** local rows are eligible for upload or a scheduled sync cycle runs
- **THEN** the system SHALL perform Supabase-backed entity operations only from the documented sync or remote orchestration layer based on persisted pending state, not from feature UI code
