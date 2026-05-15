# household-family-details (delta)

## ADDED Requirements

### Requirement: Family details requires signed-in cloud session

The system SHALL present **family details** (member list and owner actions) only when the user has an **active Supabase-authenticated session** suitable for household-scoped reads. When the user is not signed in, the system SHALL NOT offer the same management behavior (substitute sign-in prompt, disabled entry, or equivalent product-defined UX).

#### Scenario: Signed-in user can reach family details from Settings

- **WHEN** the user is signed in and opens the Family entry from compact Settings as implemented
- **THEN** the app SHALL navigate to the family details experience or show an explicit blocking reason (e.g. household not ready) consistent with design

#### Scenario: Unsigned user does not get member management

- **WHEN** the user is not signed in
- **THEN** the system SHALL NOT allow the same family member management actions as a signed-in household member

### Requirement: Family details lists household members

The family details screen SHALL list members of the **current** synced household (derived from the client’s resolved `household_id` and Supabase `household_members` or equivalent authorized API). Each listed member SHALL be identifiable per design (e.g. stable id, placeholder label, or profile label when available).

#### Scenario: Member rows reflect server membership

- **WHEN** family details loads successfully for a household with one or more members
- **THEN** the screen SHALL show one entry per distinct household member returned by the authorized query

#### Scenario: Empty household shows empty state

- **WHEN** the household has only the current user or zero additional rows per design
- **THEN** the screen SHALL present an understandable empty or minimal-members state without crashing

### Requirement: Only household owner may add members via QR scan

The system SHALL restrict **add member** / **QR scan** actions to the user who is the **household owner** for that household (per persisted `role` or design-approved rule). Non-owners MAY view the list if allowed by design but SHALL NOT complete an add-member scan that mutates membership.

#### Scenario: Owner can start add-member scan

- **WHEN** the current user is the household owner and family details is shown
- **THEN** the system SHALL provide an affordance to scan an invite QR to add a member

#### Scenario: Non-owner cannot add via scan

- **WHEN** the current user is not the household owner
- **THEN** the system SHALL not complete adding another member via the owner-only scan flow

### Requirement: Add member rejects duplicates

The system SHALL NOT create a duplicate `household_members` row for the same `(household_id, user_id)`. If the invitee is already a member, the user SHALL receive clear feedback (e.g. “Already in family”) and no destructive side effects.

#### Scenario: Duplicate invite is rejected gracefully

- **WHEN** the scanned invite resolves to a user who is already in the household
- **THEN** the system SHALL not insert a duplicate membership and SHALL inform the user

### Requirement: Add member uses QR scan of invite payload

The **add member** flow SHALL use device camera scanning to read the invite payload (same family-invite QR contract as profile details unless superseded by design). Successful scan SHALL trigger the server-authorized membership mutation path defined in design (e.g. RPC).

#### Scenario: Successful scan leads to membership mutation attempt

- **WHEN** the owner completes a valid scan of an invite QR and the backend accepts the operation
- **THEN** the household SHALL gain the new member (or show an explicit server error)
