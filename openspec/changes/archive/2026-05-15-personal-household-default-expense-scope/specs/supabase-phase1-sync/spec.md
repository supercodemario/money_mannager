# supabase-phase1-sync (delta)

## ADDED Requirements

### Requirement: Sync resolves household from default expense preference

The sync orchestration layer SHALL determine the active `household_id` for household-scoped push and pull using the persisted **default expense household** when that id is valid for the current session user. When the preference is missing or invalid, the system SHALL fall back to the user’s **personal** household. The system SHALL NOT override an explicit valid preference with an arbitrary `LIMIT 1` membership selection.

#### Scenario: Manual sync uses stored default

- **WHEN** an authenticated user runs manual sync and a valid default expense household id is stored
- **THEN** household-scoped entities SHALL use that id for the sync cycle

#### Scenario: Fallback to personal household

- **WHEN** the stored default is absent or no longer valid for membership
- **THEN** the system SHALL use the user’s personal household id for household-scoped sync after persisting the corrected preference

## MODIFIED Requirements

### Requirement: Logout with unsynced data uses guarded sync screen

If the user requests logout while unsynced rows exist **and** household-scoped cloud upload **can** run for the user’s resolved **default expense household** (including the personal household), the app MUST show a dedicated sync progress screen before logout. On failure, the screen MUST show error reason and provide `Retry` and `Logout without sync` actions.

If unsynced rows exist **and** household-scoped upload **cannot** run (for example the client cannot resolve any expense household), the app MUST NOT present a sync progress screen that retries the same failing precondition indefinitely; it MUST offer completing logout with an explicit warning that unsynced local changes may be lost.

#### Scenario: Logout sync succeeds

- **WHEN** logout is requested and unsynced rows exist and pre-logout sync succeeds
- **THEN** the app SHALL complete logout and wipe local database as defined by product rules

#### Scenario: Logout sync fails and user retries

- **WHEN** pre-logout sync fails and the user taps `Retry`
- **THEN** the app SHALL attempt the sync flow again and update progress/error state accordingly

#### Scenario: Logout without sync

- **WHEN** pre-logout sync fails and the user taps `Logout without sync`
- **THEN** the app SHALL complete logout, wipe local database, and MAY lose unsynced local-only or pending rows

#### Scenario: Logout skips guarded sync when upload cannot run

- **WHEN** logout is requested and unsynced rows exist but no expense household can be resolved for upload
- **THEN** the app SHALL NOT enter an unbounded sync retry loop and SHALL offer logout with explicit data-loss acknowledgment
