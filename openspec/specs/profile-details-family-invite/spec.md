# profile-details-family-invite Specification

## Purpose

Users need a **profile details** surface for **identity** (display name, avatar), **cloud sync** account status and sign-in/manage actions, **sign out**, and **destructive local data removal** with confirmation. Family invite **QR** and **scan-to-join** are **not** on this screen; they are provided from **family list** and related household flows.

## Requirements

### Requirement: Profile details screen shows identity and avatar

The system SHALL provide a **profile details** screen that displays the current user’s **display name** (from the persisted user profile) and a prominent **avatar** derived deterministically from a **stable user identifier** (consistent with the app’s member avatar rules: e.g. Supabase auth user id when cloud identity applies, otherwise the persisted local profile id).

#### Scenario: Display name is visible

- **WHEN** the user opens the profile details screen and a user profile exists
- **THEN** the screen SHALL show that profile’s display name

#### Scenario: Avatar reflects stable identity

- **WHEN** the profile details screen is shown for the current profile
- **THEN** the screen SHALL render an avatar keyed to the stable identifier rule above so the glyph remains stable when the display name changes

### Requirement: Profile details includes cloud sync account section

The profile details screen SHALL include the **cloud sync** account summary and actions that were previously shown on the compact Settings screen: when Supabase is not configured, a concise not-configured message; when configured, signed-out users SHALL see sign-in / open-auth affordances, and signed-in users SHALL see session identity (e.g. email) and a path to **manage account** (same class of behavior as the existing `CloudSyncSettingsSection`).

#### Scenario: Cloud sync appears on profile details

- **WHEN** the user opens the profile details screen
- **THEN** the screen SHALL include the cloud sync account section described above (not only on the Settings tab)

#### Scenario: Manage account still opens auth surface

- **WHEN** a signed-in user uses the manage-account (or equivalent) control on profile details cloud sync section
- **THEN** the app SHALL navigate to the same auth / account management surface as today’s cloud sync card (`AuthScreen` or successor)

### Requirement: Profile details offers sign out

The profile details screen SHALL provide **sign out** when signing out is applicable to the current session. Sign out SHALL follow the same **sync-before-logout** and session teardown behavior as the app’s primary authenticated sign-out path (no divergent “light” logout unless explicitly specified elsewhere).

#### Scenario: User can initiate sign out

- **WHEN** the user is in a state where sign out is offered on profile details
- **THEN** the screen SHALL expose an affordance to sign out that routes through the standard logout flow (including sync-before-logout when required)

### Requirement: Profile details offers destructive account action with confirmation

The profile details screen SHALL provide a **destructive** account or data action (e.g. delete account or reset local identity) that **cannot** complete without an explicit **confirmation** step.

#### Scenario: Destructive action requires confirmation

- **WHEN** the user taps the destructive action control
- **THEN** the system SHALL present a confirmation step that clearly describes the impact before any irreversible mutation

#### Scenario: Dismissal cancels deletion

- **WHEN** the user dismisses the confirmation without confirming
- **THEN** the system SHALL not perform the destructive deletion

### Requirement: Profile details does not host household QR or scan

The profile details screen SHALL **not** display a QR code for household or family invite, and SHALL **not** embed a camera **scan-to-join** affordance for household flows.

#### Scenario: No QR on profile details

- **WHEN** the user views the profile details screen
- **THEN** the screen SHALL not include a QR code widget for family or household invite

#### Scenario: No scan-to-join on profile details

- **WHEN** the user views the profile details screen
- **THEN** the screen SHALL not offer a scan-to-join camera entrypoint for household membership

### Requirement: Display-name editing remains available from profile details

The system SHALL retain display-name editing on the **profile details** screen (e.g. an Edit affordance) using the existing profile service flow.

#### Scenario: User updates display name from profile details

- **WHEN** the user uses the Edit affordance for display name and saves a valid name
- **THEN** the profile display name is updated via the existing profile service flow
