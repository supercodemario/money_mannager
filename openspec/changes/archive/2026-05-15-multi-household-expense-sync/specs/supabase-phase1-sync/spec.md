# supabase-phase1-sync (delta)

## REMOVED Requirements

### Requirement: Sync resolves household from default expense preference

**Reason:** Sync scope is all households the user belongs to, not a single active household from preference.

**Migration:** Remove client use of `sync_household_id` for pull/push; keep default expense household for new-row attribution only (see `personal-household-expense-scope` delta).

## ADDED Requirements

### Requirement: Expense and recurring sync uses all member households

The sync orchestration layer SHALL pull household-scoped entities (expenses, recurring templates, recurring occurrences) for **every** household the authenticated user belongs to in a single incremental sync cycle. The client SHALL NOT restrict pull queries to a single active `household_id`. Row Level Security SHALL remain the authority for which rows are visible.

#### Scenario: User in multiple families receives merged pull

- **WHEN** an authenticated user is a member of more than one household and runs manual or background sync
- **THEN** the client SHALL pull remote rows from all those households (including expenses created by other members) subject to RLS

#### Scenario: Push sends per-row household

- **WHEN** the client uploads a pending local expense or recurring row
- **THEN** the upsert SHALL include that row’s stored `household_id` and `auth_user_id` equal to the signed-in user

#### Scenario: Pull does not require resolved sync household id

- **WHEN** manual sync runs and the user has at least one household membership
- **THEN** sync SHALL proceed without requiring a persisted single-household sync scope key

## MODIFIED Requirements

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
