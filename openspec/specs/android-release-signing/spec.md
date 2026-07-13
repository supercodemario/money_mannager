# android-release-signing Specification

## Purpose

Support Play-ready Android identity and locally configured upload-key signing for release App Bundles without committing secrets.

## Requirements

### Requirement: Release builds use upload-key signing from local key.properties

The Android release build SHALL sign with a dedicated upload keystore when `android/key.properties` is present. Credentials and keystore paths MUST be loaded from that file (not hardcoded in Gradle sources). The keystore file and `key.properties` MUST remain gitignored and MUST NOT be committed to version control.

#### Scenario: Release signing configured from key.properties

- **WHEN** `android/key.properties` exists and points at a valid upload keystore under `android/`
- **THEN** the `release` build type uses `signingConfigs.release` with store file, alias, and passwords from that properties file

#### Scenario: Secrets stay out of git

- **WHEN** a developer inspects `android/.gitignore` and the git index for keystore/properties files
- **THEN** `key.properties` and `*.jks` / `*.keystore` are ignored and are not tracked

### Requirement: Play-ready application id

The Android app SHALL use application id (and matching Gradle namespace) `com.nexkind.homelybudget` for release and debug product identity on Android.

#### Scenario: Package identity is com.nexkind.homelybudget

- **WHEN** the Android app Gradle configuration is read
- **THEN** `applicationId` is `com.nexkind.homelybudget` (not `com.example.money_manager`)

### Requirement: Signed App Bundle for Play upload

The project SHALL support producing a signed Android App Bundle suitable for Google Play upload (Play App Signing enabled, greenfield listing) via the standard Flutter release bundle command.

#### Scenario: Build signed app bundle

- **WHEN** a developer with a valid local keystore and `key.properties` runs `flutter build appbundle`
- **THEN** a release `.aab` is produced under the Flutter Android bundle output path and is signed with the configured upload key
