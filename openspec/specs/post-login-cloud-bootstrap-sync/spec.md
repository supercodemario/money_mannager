## ADDED Requirements

### Requirement: Post-login bootstrap can pull existing cloud expenses into local storage
After successful authentication, the system MUST provide an explicit sync flow that can fetch existing Supabase expenses and merge them into local storage even when there are no `local_only` rows.

#### Scenario: Existing cloud user signs in on empty local device
- **WHEN** an authenticated user with existing Supabase expenses signs in on a device where local expenses are empty
- **THEN** the app SHALL offer or execute a bootstrap sync that pulls cloud expenses into local storage

### Requirement: Bootstrap sync reports stage progress and supports retry
The bootstrap cloud-to-local flow MUST provide user-visible stage progress and MUST surface recoverable failures with an explicit retry path.

#### Scenario: Bootstrap sync fails during pull
- **WHEN** the bootstrap sync fails while fetching remote rows
- **THEN** the app SHALL show an error state with a retry action that re-runs the bootstrap sync path

### Requirement: Bootstrap flow avoids repeated forced prompts after completion
Once bootstrap sync completes successfully for a signed-in session/device state, the app MUST NOT repeatedly force the same blocking post-login bootstrap prompt without a new trigger condition.

#### Scenario: User re-opens auth screen after successful bootstrap
- **WHEN** bootstrap sync has already completed successfully and no new blocking trigger exists
- **THEN** the app SHALL allow normal navigation without forcing the bootstrap prompt again
