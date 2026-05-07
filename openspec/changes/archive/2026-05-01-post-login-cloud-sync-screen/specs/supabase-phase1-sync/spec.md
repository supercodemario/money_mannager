## MODIFIED Requirements

### Requirement: Login/signup prompts for local-only data sync

After a successful login or signup, if local-only expense rows exist, the app MUST present a dedicated **post-login cloud sync** screen before returning the user to the rest of the app. That screen MUST show the count of local-only expenses eligible for this flow (the same count used to decide that the screen is shown). The screen MUST offer an explicit primary control to **start sync** and an explicit control to **defer sync** without uploading. When the user starts sync, the app MUST show visible progress for the orchestrated stages **preparing** local data for upload, **uploading** local changes, and **downloading** latest cloud data, consistent with manual sync stage reporting used elsewhere in the app. When sync completes successfully, the screen MUST show a **completion** state and an explicit control to dismiss the flow. When sync fails, the screen MUST show the error reason and offer **Retry** (re-run the same sync path) and **defer** without signing out.

When the user completes sync from this flow, the app MUST promote eligible local-only rows to uploadable state, perform sync push then pull, and keep the user signed in. When the user defers from this flow, the app MUST keep those rows in `local_only` state and MUST NOT upload them in that flow.

#### Scenario: User starts sync from post-login screen

- **WHEN** login or signup succeeds and local-only expense rows are present and the user opens the post-login cloud sync screen and chooses to start sync
- **THEN** the app SHALL promote eligible local-only rows to uploadable state, perform sync push then pull, and keep the user signed in

#### Scenario: User defers sync from post-login screen

- **WHEN** login or signup succeeds and local-only expense rows are present and the user chooses to defer sync from the post-login cloud sync screen
- **THEN** the app SHALL keep those rows in `local_only` state and SHALL NOT upload them in that flow

#### Scenario: Post-login sync shows eligible count

- **WHEN** the post-login cloud sync screen is shown after authentication
- **THEN** the user SHALL see the number of expenses currently in `local_only` sync status that are eligible for upload in this flow

#### Scenario: Post-login sync shows stage progress

- **WHEN** the user has started sync from the post-login cloud sync screen
- **THEN** the user SHALL see progress feedback aligned to preparing, uploading, and downloading stages until the sync completes or fails

#### Scenario: Post-login sync completes

- **WHEN** sync started from the post-login cloud sync screen finishes without error
- **THEN** the app SHALL show a completion state and SHALL allow the user to dismiss the screen explicitly

#### Scenario: Post-login sync fails and user retries

- **WHEN** sync started from the post-login cloud sync screen fails and the user selects **Retry**
- **THEN** the app SHALL attempt the same sync path again and update progress and error state accordingly

#### Scenario: No local-only rows after auth

- **WHEN** login or signup succeeds and no local-only expense rows exist
- **THEN** the app SHALL NOT require the post-login cloud sync screen for that condition and SHALL follow the existing navigation behavior for closing or continuing the auth flow
