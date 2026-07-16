## Why

Broken or incompatible Android builds can keep running after a critical fix ships to Play Store. A hard force-update gate—comparing the installed `versionCode` to a remote minimum—ensures users below that build must update before continuing.

## What Changes

- Read the installed Android app build number (`versionCode` / Flutter build number) at runtime.
- Store a minimum required Android build (and Play Store URL / message) in a Supabase table readable without login.
- On Android cold start and when returning from background, fetch (or use cached) minimum build and compare.
- If local build is lower than the remote minimum, show a non-dismissible update screen and open the Play Store.
- Hard-only: no soft “update available” prompt in this change.
- Offline / fetch failure: use last cached minimum when available; otherwise fail open (do not block the app).
- iOS and soft-update paths are out of scope for this change.

## Capabilities

### New Capabilities

- `android-force-update`: Android-only hard force update based on remote minimum build number from Supabase, with local cache and Play Store navigation.

### Modified Capabilities

- *(none)*

## Impact

- **Client**: Launch / app lifecycle gate (near `main` / shell), force-update UI screen, `package_info_plus` (or equivalent) for build number, `url_launcher` (or equivalent) for Play Store.
- **Local storage**: SharedPreferences (or similar) cache for last known `min_build` + metadata.
- **Supabase**: New public/anon-readable policy table (or row) for Android minimum build; SQL migration / RLS policy docs in repo.
- **Ops**: When releasing a breaking Android build, bump Play `versionCode` and raise `min_android_build` in Supabase after the store build is live.
- **Non-goals**: iOS, soft update, Play In-App Updates API (can layer later).
