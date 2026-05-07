## ADDED Requirements

### Requirement: Unsigned local captures are marked local-only

When no authenticated Supabase session exists, newly saved sync-eligible entities MUST remain in local storage and MUST be marked with sync status `local_only` until the user explicitly chooses to sync after authentication.

#### Scenario: Create expense while signed out

- **WHEN** the user creates a new expense while not logged in
- **THEN** the expense SHALL be stored locally with sync status `local_only` and SHALL NOT be uploaded to Supabase

### Requirement: Login/signup prompts for local-only data sync

After a successful login or signup, if local-only rows exist, the app MUST prompt the user to choose whether to sync those rows now. Choosing sync MUST enqueue those rows for upload and then run push followed by pull.

#### Scenario: User chooses sync now

- **WHEN** login or signup succeeds and local-only rows are present and the user selects **Yes/Sync now**
- **THEN** the app SHALL promote eligible local-only rows to uploadable state, perform sync push then pull, and keep user signed in

#### Scenario: User defers sync

- **WHEN** login or signup succeeds and local-only rows are present and the user selects **Not now**
- **THEN** the app SHALL keep those rows in local-only state and SHALL NOT upload them in that flow

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
