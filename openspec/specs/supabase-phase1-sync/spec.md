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

#### Scenario: Automatic expense push does not pull

- **WHEN** the automatic expense sync cycle runs for pending expenses
- **THEN** the system SHALL upsert those pending expenses when session and OS connectivity allow
- **AND** SHALL NOT perform a remote pull in that same automatic cycle

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

After a successful login or signup, the app MUST provide a post-auth sync flow that supports both:
1) uploading local-only sync-eligible rows when they exist, including expenses, recurring payment templates, recurring payment occurrences, and expense profile preferences, and
2) pulling existing cloud recurring payment templates, cloud expenses, recurring payment occurrences, and the signed-in user's expense profile into local storage even when local-only rows are zero.

The flow MUST show explicit progress stages for preparing, uploading (when applicable), and downloading latest cloud data, consistent with manual sync stage reporting used elsewhere in the app. On failure, the flow MUST show error reason and offer Retry and defer behavior without forcing sign-out.

When the user starts sync from this flow, the app MUST run the orchestrated path for the current condition:
- if local-only sync-eligible rows exist, promote eligible rows and execute push then pull;
- if local-only sync-eligible rows do not exist, execute pull-only or cloud-first bootstrap behavior that merges remote data into local storage.

When pushing or pulling remote data, the app MUST preserve dependency order: recurring payment templates before expenses, and recurring payment occurrences after expenses.

When the user defers from this flow, the app MUST keep local-only rows unchanged and MUST NOT upload them in that flow.

#### Scenario: User starts sync from post-login screen with local-only rows

- **WHEN** login or signup succeeds and local-only sync-eligible rows are present and the user chooses to start sync
- **THEN** the app SHALL promote eligible local-only rows to uploadable state, perform sync push then pull, and keep the user signed in

#### Scenario: Existing cloud user starts sync with zero local-only rows

- **WHEN** login or signup succeeds and zero local-only sync-eligible rows exist and the user starts post-login sync
- **THEN** the app SHALL perform a cloud-to-local pull that merges remote recurring payment templates, remote expenses, recurring payment occurrences, and the signed-in user's expense profile into local storage

#### Scenario: User defers sync from post-login screen

- **WHEN** login or signup succeeds and the user chooses to defer sync from the post-login sync flow
- **THEN** the app SHALL keep local-only rows in `local_only` state and SHALL NOT upload them in that flow

#### Scenario: Post-login sync shows stage progress

- **WHEN** the user has started sync from the post-login sync flow
- **THEN** the user SHALL see progress feedback aligned to preparing, uploading, and downloading stages until sync completes or fails

#### Scenario: Post-login sync completes

- **WHEN** sync started from the post-login sync flow finishes without error
- **THEN** the app SHALL show a completion state and SHALL allow the user to dismiss the screen explicitly

#### Scenario: Post-login sync fails and user retries

- **WHEN** sync started from the post-login sync flow fails and the user selects Retry
- **THEN** the app SHALL attempt the same sync path again and update progress and error state accordingly

### Requirement: Authenticated users can manually trigger cloud-to-local refresh

The system MUST allow an authenticated user to manually trigger a sync that refreshes local recurring payment templates, expenses, recurring payment occurrences, and the signed-in user's expense profile from Supabase even when there are no local pending or local-only rows.

#### Scenario: Manual refresh from signed-in state

- **WHEN** an authenticated user invokes manual sync while local pending/local-only counts are zero
- **THEN** the app SHALL run a cloud-to-local pull and merge remote recurring payment templates, remote expense rows, recurring payment occurrences, and the signed-in user's expense profile into local storage

### Requirement: Logout with unsynced data uses guarded sync screen

If the user requests logout while unsynced rows exist **and** cloud sync is allowed for the current session (Supabase configured and authenticated), the app MUST show a dedicated sync progress screen before logout when upload can run. The gate MUST NOT depend on resolving a single active `household_id` for sync scope.

If unsynced rows exist **and** cloud sync cannot run (for example the user is not signed in), the app MUST NOT present a sync progress screen that retries indefinitely; it MUST offer completing logout with an explicit warning that unsynced local changes may be lost where applicable.

#### Scenario: Logout sync succeeds

- **WHEN** logout is requested and unsynced rows exist and pre-logout sync succeeds
- **THEN** the app SHALL complete logout and wipe local database as defined by product rules

#### Scenario: Logout sync fails and user retries

- **WHEN** pre-logout sync fails and the user taps `Retry`
- **THEN** the app SHALL attempt the sync flow again and update progress/error state accordingly

#### Scenario: Logout without sync

- **WHEN** pre-logout sync fails and the user taps `Logout without sync`
- **THEN** the app SHALL complete logout, wipe local database, and MAY lose unsynced local-only or pending rows

#### Scenario: Logout skips guarded sync when cloud sync cannot run

- **WHEN** logout is requested and unsynced rows exist but the user has no authenticated cloud session
- **THEN** the app SHALL NOT enter an unbounded sync retry loop and SHALL offer logout with explicit data-loss acknowledgment

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

### Requirement: Background sync uses automatic expense push only

When the sync orchestrator reacts to local database pending state or session changes outside an explicit user-initiated manual sync, it SHALL run the automatic expense push cycle (expenses only, no pull) rather than a full push-then-pull cycle for all entity types.

#### Scenario: Pending expense watch triggers auto push

- **WHEN** a new or updated expense row becomes `pending` and the orchestrator schedules a background cycle
- **THEN** the orchestrator SHALL invoke automatic expense push only
- **AND** SHALL NOT pull remote entities in that background cycle

#### Scenario: Manual sync remains full cycle

- **WHEN** the user or app invokes explicit manual sync (for example settings sync, post-login sync, or logout preflight)
- **THEN** the orchestrator SHALL run full push-then-pull for all phase-1 in-scope entities per existing requirements

