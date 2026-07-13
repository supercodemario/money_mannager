## Why

Release builds currently sign with the debug keystore and use the placeholder application id `com.example.money_manager`, so the app cannot be uploaded to Google Play as a production AAB. We need a local upload-key signing setup and a Play-ready application id before the first Play Console listing.

## What Changes

- **BREAKING** (install identity): Change Android `applicationId` / namespace to `com.nexkind.homelybudget` (new Play package; not an in-place upgrade of any existing Play listing).
- Add a local upload keystore at `android/homeratio-keystore.jks` (gitignored) and a gitignored `android/key.properties` that points Gradle at that keystore.
- Wire `signingConfigs.release` in `android/app/build.gradle.kts` so `release` builds use the upload key when `key.properties` is present; keep debug signing for debug builds.
- Document the one-time keystore generation and `flutter build appbundle` flow for Play upload (Play App Signing enabled; greenfield app).
- Ensure `android/.gitignore` continues to exclude `key.properties` and `*.jks` / `*.keystore` so secrets never enter git.

## Capabilities

### New Capabilities

- `android-release-signing`: Requirements for release signing via local `key.properties` + upload keystore, Play-ready `applicationId`, and producing a signed App Bundle without committing secrets.

### Modified Capabilities

- (none)

## Impact

- `android/app/build.gradle.kts` — release signing config and `applicationId` / `namespace`
- `android/key.properties` — local-only (gitignored); never committed
- `android/homeratio-keystore.jks` — local-only upload keystore (gitignored)
- `android/.gitignore` — confirm ignore rules for keystore and properties
- Optional short note in project docs or change tasks for Play Console first upload
- No Dart/runtime behavior changes; Android package identity change only
