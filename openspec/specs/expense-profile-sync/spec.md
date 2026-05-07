## ADDED Requirements

### Requirement: Auth-user scoped expense profile storage

The system SHALL store synced expense profile preferences in Supabase scoped to the authenticated user, not to a household.

#### Scenario: Signed-in user reads only own profile
- **WHEN** an authenticated user reads expense profile preferences from Supabase
- **THEN** the system SHALL return only the profile row whose auth user identifier matches the current session

#### Scenario: Household member cannot read another profile
- **WHEN** another authenticated household member reads expense profile preferences
- **THEN** the system SHALL NOT return profile preferences owned by a different auth user

### Requirement: Local expense profile changes are sync eligible

The system SHALL mark local `expense_limit_preferences` changes as sync eligible using local-first sync state, preserving unsigned or unavailable-cloud edits until an authenticated sync path promotes or uploads them.

#### Scenario: Save profile while signed in
- **WHEN** the user saves monthly income, monthly savings, or unpaid-recurring exclusion while Supabase sync is allowed
- **THEN** the system SHALL persist the profile locally and mark it pending upload

#### Scenario: Save profile while signed out
- **WHEN** the user saves monthly income, monthly savings, or unpaid-recurring exclusion without an authenticated Supabase session
- **THEN** the system SHALL persist the profile locally and keep it local-only until the user explicitly starts authenticated sync

### Requirement: Expense profile upload

The system SHALL upload pending expense profile preferences to Supabase from the sync layer using an idempotent auth-user scoped upsert.

#### Scenario: Pending profile uploads
- **WHEN** sync runs with a pending local expense profile and a valid authenticated session
- **THEN** the system SHALL upsert the profile to Supabase for the current auth user and mark the local profile synced after success

#### Scenario: Profile upload fails
- **WHEN** a pending expense profile upload fails
- **THEN** the system SHALL keep the local profile available and mark it error or otherwise retryable without losing the user's saved values

### Requirement: Expense profile download

The system SHALL pull the signed-in user's remote expense profile from Supabase during sync and merge it into local `expense_limit_preferences`.

#### Scenario: Remote profile hydrates local storage
- **WHEN** a signed-in user runs post-login bootstrap or manual refresh and Supabase contains that user's expense profile
- **THEN** the system SHALL merge the remote profile into local storage so the expense limits screen loads the restored values

#### Scenario: No remote profile exists
- **WHEN** a signed-in user runs post-login bootstrap or manual refresh and Supabase has no profile row for that user
- **THEN** the system SHALL leave local profile preferences unchanged

### Requirement: Expense profile conflicts use last-write-wins

The system SHALL resolve local and remote expense profile conflicts by comparing `updated_at` and applying the newer version.

#### Scenario: Remote profile is newer
- **WHEN** a pulled remote profile has `updated_at` greater than the local profile row
- **THEN** the system SHALL update local monthly income, monthly savings, unpaid-recurring exclusion, and sync metadata from the remote profile

#### Scenario: Local profile is newer
- **WHEN** a pulled remote profile has `updated_at` older than the local profile row
- **THEN** the system SHALL keep the local profile values and preserve their sync eligibility
