# personal-household-expense-scope Specification

## Purpose
TBD - created by archiving change personal-household-default-expense-scope. Update Purpose after archive.
## Requirements
### Requirement: Personal household exists for every cloud user

The system SHALL ensure each Supabase-authenticated user has exactly one **personal** household record to which they belong as **owner**, auto-created at successful **sign-up** (account creation). The operation SHALL be **idempotent**: repeated invocations SHALL NOT create duplicate personal households for the same user.

#### Scenario: New sign-up provisions personal household

- **WHEN** a user completes cloud sign-up and obtains an authenticated session
- **THEN** the system SHALL create or resolve a personal household for that user before the user is expected to sync household-scoped expenses

#### Scenario: Idempotent ensure for existing user

- **WHEN** an already signed-in user invokes the personal household ensure path again
- **THEN** the system SHALL return the existing personal household identifier without creating a second personal household

### Requirement: Personal household is not a collaboration target

The system SHALL NOT allow **invite**, **join**, **add member via QR**, or **share household QR** flows to add other users to a **personal** household or to use a personal household id as a join/invite target. The signed-in owner SHALL remain the only member for personal households.

#### Scenario: Join by id to personal household is rejected

- **WHEN** a user attempts to join a household id that identifies a personal household
- **THEN** the system SHALL reject the operation with a clear client-visible outcome and SHALL NOT insert a new `household_members` row for another user

#### Scenario: Invite flows do not target personal household

- **WHEN** product surfaces would normally expose invite or share for a shared household
- **THEN** those surfaces SHALL NOT be shown for a personal household row

### Requirement: Default expense household preference

The system SHALL persist a **default expense household** identifier for signed-in users, selected from the set containing the user’s personal household and all shared households where the user is a member. New expenses and sync orchestration SHALL use this default when valid; if the stored id is invalid (membership lost), the system SHALL fall back to the personal household and update persisted preference accordingly.

#### Scenario: User selects shared family as default

- **WHEN** the user selects a shared household they belong to as default in preferences
- **THEN** subsequent new expenses and sync SHALL use that household id until changed

#### Scenario: Fallback when membership ends

- **WHEN** the stored default points to a household the user no longer belongs to
- **THEN** the system SHALL clear or replace that preference with the personal household and continue without throwing due to missing membership

### Requirement: Personal household visible in family list without sharing affordances

The family list experience MAY list the user’s personal household alongside shared households. For the personal household row, the system SHALL NOT present **household QR**, **invite**, or **share id** entry points that exist for shared households.

#### Scenario: Personal row has no QR action

- **WHEN** the signed-in user views the family list and a personal household row is shown
- **THEN** per-household **show QR** (or equivalent) SHALL NOT be available for that row

