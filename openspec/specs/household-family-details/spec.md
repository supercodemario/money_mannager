# household-family-details Specification

## Purpose

Signed-in users manage **household membership** from Settings: see members of the synced household, and **owners** add others by scanning an invite QR backed by Supabase `household_members` and server RPC.
## Requirements
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

The **add member** flow SHALL use device camera scanning to read the **invite payload** defined in product/design (encoding the invitee’s stable identity, e.g. Supabase auth user id when the invitee is cloud-authenticated, otherwise a stable client profile id as approved by design). Successful scan SHALL trigger the server-authorized membership mutation path (e.g. RPC). The invite QR **MAY** be shown from **family list** or **household QR share** surfaces; it **SHALL NOT** be required to originate from the profile details screen.

#### Scenario: Successful scan leads to membership mutation attempt

- **WHEN** the owner completes a valid scan of an invite QR and the backend accepts the operation
- **THEN** the household SHALL gain the new member (or show an explicit server error)

### Requirement: Household family-details behavior remains satisfied under modular features

The user journeys and constraints described in this specification (signed-in access, member listing, owner-only add via scan, duplicate rejection, QR scan contract) SHALL remain satisfied when those screens are implemented across the **household-flow-features** module set. This requirement does not relax any existing SHALL in the baseline content above; it only ties modular packaging to those obligations.

#### Scenario: Owner add-member scan still enforced after modularization

- **WHEN** the current user is not the household owner and opens the family members experience from the modular feature set
- **THEN** the system SHALL still not complete the owner-only add-member scan flow in violation of the baseline household-family-details rules

#### Scenario: Modular navigation does not bypass signed-in gating

- **WHEN** the user is not signed in for cloud household management
- **THEN** the modular family list and related entrypoints SHALL still not expose the same management behavior as a signed-in household member, consistent with this specification

### Requirement: Personal household omits collaboration affordances

When the active household is the user’s **personal** household, the family details and family list surfaces SHALL NOT present **household QR share**, **add member via QR scan**, **invite**, or other entry points whose purpose is to add or onboard additional members to that household.

#### Scenario: Personal household row has no show QR

- **WHEN** the user views a list of households that includes their personal household
- **THEN** the app SHALL NOT offer per-household QR or share-id actions for the personal household row

#### Scenario: Personal household members screen does not offer owner scan-to-add

- **WHEN** the user opens members or family details for their personal household
- **THEN** the app SHALL NOT show the add-member QR scan affordance used for shared households

### Requirement: Signed-in user with only personal household still reaches family experience

When the user is signed in and has a personal household but **no** shared households (or chooses to view family), the app SHALL still allow navigation to the family list or equivalent experience without treating “no shared family” as an unsigned or error state solely for that reason.

#### Scenario: Family entry from Settings when only personal exists

- **WHEN** the user taps the Family entry from compact Settings and has only a personal household
- **THEN** the app SHALL present the family list (or equivalent) showing the personal household row and applicable shared rows, not a blocking “household not ready” error solely due to lack of shared households

