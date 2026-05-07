## ADDED Requirements

### Requirement: User profile is persisted locally

The system MUST store at least one **user profile** record on device in SQLite via Drift, with a stable TEXT primary key (`id`, UUID) and a non-empty **display name**. The record SHALL be used to attribute expenses (`created_by_user_id`) and to support future **family** features without schema breakage.

#### Scenario: First launch creates a default profile

- **WHEN** the app runs for the first time after this capability ships and no user profile exists
- **THEN** the system SHALL create exactly one user profile row with a new UUID and a default or user-provided display name per product rules

### Requirement: Profile fields support future extension

The persisted profile MUST include `created_at` and `updated_at` (UTC epoch milliseconds). Additional nullable columns (e.g. avatar reference, household linkage) MAY be added by migration in later changes; this requirement does not mandate a specific column set beyond id, display name, and timestamps unless captured in `design.md`.

#### Scenario: Profile can be read for display

- **WHEN** a feature needs the current user’s display name
- **THEN** the system SHALL read it from the local profile store via the repository boundary

### Requirement: No remote account required

Creating or reading the local user profile MUST NOT require network access or remote authentication in this capability.

#### Scenario: Offline profile access

- **WHEN** the device is offline
- **THEN** the system SHALL still read and update the local user profile as allowed by the app
