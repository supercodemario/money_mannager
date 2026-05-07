## MODIFIED Requirements

### Requirement: Login/signup prompts for local-only data sync

After a successful login or signup, the app MUST provide a post-auth sync flow that supports both:
1) uploading local-only expense rows when they exist, and
2) pulling existing cloud expenses into local storage for authenticated users even when local-only rows are zero.

The flow MUST show explicit progress stages for preparing, uploading (when applicable), and downloading latest cloud data, consistent with manual sync stage reporting used elsewhere in the app. On failure, the flow MUST show error reason and offer Retry and defer behavior without forcing sign-out.

When the user starts sync from this flow, the app MUST run the orchestrated path for the current condition:
- if local-only rows exist, promote eligible rows and execute push then pull;
- if local-only rows do not exist, execute pull-only or cloud-first bootstrap behavior that merges remote data into local storage.

When the user defers from this flow, the app MUST keep `local_only` rows unchanged and MUST NOT upload them in that flow.

#### Scenario: User starts sync from post-login screen with local-only rows
- **WHEN** login or signup succeeds and local-only expense rows are present and the user chooses to start sync
- **THEN** the app SHALL promote eligible local-only rows to uploadable state, perform sync push then pull, and keep the user signed in

#### Scenario: Existing cloud user starts sync with zero local-only rows
- **WHEN** login or signup succeeds and zero local-only rows exist and the user starts post-login sync
- **THEN** the app SHALL perform a cloud-to-local pull that merges remote expenses into local storage

#### Scenario: User defers sync from post-login screen
- **WHEN** login or signup succeeds and the user chooses to defer sync from the post-login sync flow
- **THEN** the app SHALL keep local-only rows in `local_only` state and SHALL NOT upload them in that flow

#### Scenario: Post-login sync shows stage progress
- **WHEN** the user has started sync from the post-login sync flow
- **THEN** the user SHALL see progress feedback aligned to preparing, uploading, and downloading stages until sync completes or fails

#### Scenario: Post-login sync completes
- **WHEN** sync started from the post-login sync flow finishes without error
- **THEN** the app SHALL show a completion state and SHALL allow the user to dismiss the screen explicitly

#### Scenario: Post-login sync fails and user retries
- **WHEN** sync started from the post-login sync flow fails and the user selects Retry
- **THEN** the app SHALL attempt the same sync path again and update progress and error state accordingly

## ADDED Requirements

### Requirement: Authenticated users can manually trigger cloud-to-local refresh
The system MUST allow an authenticated user to manually trigger a sync that refreshes local expenses from Supabase even when there are no local pending or local-only rows.

#### Scenario: Manual refresh from signed-in state
- **WHEN** an authenticated user invokes manual sync while local pending/local-only counts are zero
- **THEN** the app SHALL run a cloud-to-local pull and merge remote expense rows into local storage
