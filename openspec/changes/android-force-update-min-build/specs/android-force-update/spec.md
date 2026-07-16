## ADDED Requirements

### Requirement: Read installed Android build number
On Android, the system MUST determine the installed application build number (Android `versionCode` / Flutter build number) for comparison against the remote minimum.

#### Scenario: Build number available on Android
- **WHEN** the force-update check runs on Android
- **THEN** the app SHALL obtain a positive integer build number for the installed app

### Requirement: Fetch minimum build from Supabase
On Android, the system MUST load the minimum required Android build from Supabase using a policy that is readable without user sign-in. A successful fetch MUST update a device-local cache of the policy.

#### Scenario: Successful policy fetch
- **WHEN** the app successfully reads the Android minimum build from Supabase
- **THEN** the app SHALL use that value for the force-update comparison
- **AND** the app SHALL persist it in a local cache for later use

### Requirement: Hard force update when below minimum
On Android, when the installed build number is less than the effective minimum build, the system MUST block normal app use and present a non-dismissible update experience that directs the user to the Play Store. Soft update prompts are out of scope.

#### Scenario: Outdated build is blocked
- **WHEN** the installed Android build is lower than the effective minimum build
- **THEN** the app SHALL show a non-dismissible update screen
- **AND** the user SHALL NOT be able to dismiss it to reach normal Home / shell content

#### Scenario: Update opens Play Store
- **WHEN** the user activates the primary update action on the force-update screen
- **THEN** the app SHALL open the configured Play Store listing for this application

#### Scenario: Current build continues
- **WHEN** the installed Android build is greater than or equal to the effective minimum build
- **THEN** the app SHALL allow normal use without showing the force-update screen

### Requirement: Check on launch and resume
On Android, the system MUST perform the force-update check on cold start after remote services are available, and MUST re-check when the app returns to the foreground.

#### Scenario: Cold start check
- **WHEN** the Android app finishes launching and can query the version policy
- **THEN** the app SHALL evaluate force-update before or as the user reaches interactive shell content

#### Scenario: Resume check
- **WHEN** the Android app returns from background to foreground
- **THEN** the app SHALL re-evaluate force-update against the latest available policy (network or cache)

### Requirement: Cached fail-open on fetch failure
When the remote policy cannot be fetched, the system MUST use the last cached minimum build if one exists. If no cache exists, the system MUST NOT block the user solely due to the fetch failure.

#### Scenario: Fetch fails with cache
- **WHEN** the Supabase policy fetch fails
- **AND** a previously cached minimum build exists
- **THEN** the app SHALL compare the installed build against the cached minimum

#### Scenario: Fetch fails with no cache
- **WHEN** the Supabase policy fetch fails
- **AND** no cached minimum build exists
- **THEN** the app SHALL allow normal use (fail open)

### Requirement: Non-Android platforms skip force update
On non-Android platforms, the system MUST NOT show the Android force-update gate from this capability.

#### Scenario: iOS skips Android gate
- **WHEN** the app runs on a non-Android platform
- **THEN** the Android force-update screen SHALL NOT be shown by this capability

### Requirement: Token-first force-update UI copy
The force-update screen MUST use shared design tokens and centralized string tokens for default visible copy when remote message text is empty.

#### Scenario: Default strings when message empty
- **WHEN** the force-update screen is shown and the remote message is empty
- **THEN** the app SHALL display copy from `AppStrings` (or equivalent centralized strings)
