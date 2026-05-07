# recurring-payments-sync Specification

## Purpose

Define phase-1 sync behavior for recurring payment templates and occurrences, including household-scoped cloud storage, local-first eligibility, ordered upload/download, and deterministic conflict and dependency handling.

## Requirements

### Requirement: Household-scoped recurring payment storage

The system SHALL store synced recurring payment templates and recurring payment occurrences in Supabase scoped to the household, using household membership authorization consistent with synced expenses.

#### Scenario: Household member reads recurring rows

- **WHEN** an authenticated household member reads recurring payment templates or occurrences from Supabase
- **THEN** the system SHALL return rows belonging to that member's household

#### Scenario: Non-member cannot read recurring rows

- **WHEN** an authenticated user reads recurring payment templates or occurrences for a household they do not belong to
- **THEN** the system SHALL NOT return those rows

### Requirement: Local recurring changes are sync eligible

The system SHALL mark recurring payment template and occurrence creates, updates, scheduling toggles, paid-state changes, and supported delete/tombstone operations as sync eligible using local-first sync state.

#### Scenario: Save recurring data while signed in

- **WHEN** the user changes a recurring template or occurrence while Supabase sync is allowed
- **THEN** the system SHALL persist the change locally and mark it pending upload

#### Scenario: Save recurring data while signed out

- **WHEN** the user changes a recurring template or occurrence without an authenticated Supabase session
- **THEN** the system SHALL persist the change locally and keep it local-only until the user explicitly starts authenticated sync

### Requirement: Recurring payment upload

The system SHALL upload pending recurring payment templates and occurrences to Supabase from the sync layer using idempotent household-scoped upserts.

#### Scenario: Pending recurring rows upload in dependency order

- **WHEN** sync runs with pending recurring templates, pending expenses, and pending recurring occurrences
- **THEN** the system SHALL upload recurring templates before expenses and recurring occurrences after expenses

#### Scenario: Recurring upload fails

- **WHEN** a recurring template or occurrence upload fails
- **THEN** the system SHALL keep the local row available and mark it error or otherwise retryable without losing the user's saved values

### Requirement: Recurring payment download

The system SHALL pull household recurring payment templates and occurrences from Supabase during sync and merge them into local Drift storage.

#### Scenario: Remote recurring rows hydrate local storage

- **WHEN** a signed-in user runs post-login bootstrap or manual refresh and Supabase contains household recurring payment data
- **THEN** the system SHALL merge templates and occurrences into local storage so recurring screens restore template and paid-month state

#### Scenario: Pull preserves dependency order

- **WHEN** recurring data and expenses are pulled from Supabase
- **THEN** the system SHALL merge recurring templates before expenses and recurring occurrences after expenses

### Requirement: Recurring payment conflicts use last-write-wins

The system SHALL resolve recurring template and occurrence conflicts by comparing `updated_at` and applying the newer version.

#### Scenario: Remote recurring row is newer

- **WHEN** a pulled remote recurring template or occurrence has `updated_at` greater than the matching local row
- **THEN** the system SHALL update local row fields and sync metadata from the remote row

#### Scenario: Local recurring row is newer

- **WHEN** a pulled remote recurring template or occurrence has `updated_at` older than the matching local row
- **THEN** the system SHALL keep the local row values and preserve their sync eligibility

### Requirement: Missing recurring dependencies are handled safely

The system SHALL avoid crashes when a pulled recurring occurrence references a missing recurring template or expense.

#### Scenario: Occurrence references missing dependency

- **WHEN** a pulled recurring occurrence references a template or expense that is not present locally after the dependency pull stages
- **THEN** the system SHALL skip, defer, or mark the occurrence retryable according to the implementation's documented strategy without losing other synced rows
