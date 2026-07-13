## Context

Release builds today use the debug signing config and `applicationId` `com.example.money_manager`. That blocks Play Console upload and is unsuitable for a production listing named HomeRatio.

Constraints already agreed:
- Secrets live in gitignored `android/key.properties` (not hardcoded in Gradle).
- Upload keystore path: `android/homeratio-keystore.jks` (gitignored; `*.jks` already ignored).
- Application id: `com.nexkind.homelybudget`.
- Play App Signing: enabled; this is a greenfield Play app (no existing listing to migrate).
- Local machine holds the upload key; Google holds the app signing key after first upload.

## Goals / Non-Goals

**Goals:**
- Produce a Play-uploadable signed App Bundle via `flutter build appbundle`.
- Use a dedicated upload keystore referenced only through `key.properties`.
- Set Android package identity to `com.nexkind.homelybudget`.
- Keep keystore and passwords out of git.

**Non-Goals:**
- CI/CD secret injection or GitHub Actions signing (local signing first).
- Changing iOS signing or bundle id.
- Migrating an existing Play listing or changing Firebase/Google Services package mappings beyond what the new applicationId requires.
- Committing passwords or keystore bytes into the repo or OpenSpec artifacts.

## Decisions

### 1. Local `key.properties` + upload keystore (not Gradle-hardcoded secrets)

**Choice:** Load `storePassword`, `keyPassword`, `keyAlias`, and `storeFile` from `android/key.properties` when the file exists; configure `signingConfigs.release` and assign it to `buildTypes.release`.

**Why:** Matches Flutter’s recommended pattern; keeps secrets off disk in VCS; `android/.gitignore` already ignores `key.properties` and `**/*.jks`.

**Alternatives considered:**
- Hardcode passwords in `build.gradle.kts` — rejected (secret leakage).
- Env-var-only signing — deferred; local file is enough for first Play upload.

### 2. Keystore location and naming

**Choice:** `android/homeratio-keystore.jks` with alias `homeRatio`; `storeFile` in properties is relative to `android/app` or resolved as `rootProject.file("../homeratio-keystore.jks")` / equivalent so Gradle finds it under `android/`.

**Why:** Single obvious path next to the Android project; name matches product branding.

### 3. Application id / namespace → `com.nexkind.homelybudget`

**Choice:** Update `applicationId` and Kotlin/Java `namespace` in `android/app/build.gradle.kts` to `com.nexkind.homelybudget`. Align MainActivity package / folder if the build requires it.

**Why:** User-selected Play package; greenfield listing so no upgrade-path constraint from `com.example.*`.

**Alternatives considered:** Keep `com.example.money_manager` — rejected (not Play-ready branding).

### 4. Play App Signing (upload key vs app signing key)

**Choice:** Sign the AAB with the local upload key; enable Play App Signing on first upload so Google re-signs with the app signing key for distribution.

**Why:** Standard Play flow; upload key can be reset via Play Console if lost (with Google’s process); app signing key stays with Google.

### 5. Graceful missing `key.properties`

**Choice:** Prefer: if `key.properties` is missing, release signing falls back to debug (current behavior) or fails clearly with a message — pick fail-fast or debug-fallback consistently in Gradle. Recommended: only apply release signing when the file exists; document that Play builds require the file.

**Why:** Contributors without the keystore can still build debug; release AAB for Play requires local secrets.

## Risks / Trade-offs

- [Lost upload keystore] → Mitigation: back up `homeratio-keystore.jks` and `key.properties` offline; use Play Console upload-key reset if needed.
- [Secrets accidentally committed] → Mitigation: rely on `.gitignore`; never add keystore/properties in tasks that stage files; do not put password values in OpenSpec docs.
- [applicationId change orphans old debug installs] → Mitigation: expected for greenfield; uninstall old `com.example.*` builds on devices.
- [MainActivity / namespace mismatch after id change] → Mitigation: update package path or `namespace` so AGP builds succeed; verify with `flutter build appbundle`.

## Migration Plan

1. Generate keystore locally (once) if missing; write `key.properties` (gitignored).
2. Wire Gradle signing + applicationId.
3. Run `flutter build appbundle` and confirm output under `build/app/outputs/bundle/release/`.
4. Create Play Console app with package `com.nexkind.homelybudget`, enable Play App Signing, upload AAB.
5. Rollback: revert Gradle/id changes; keep local keystore for future use. Cannot “rollback” a published Play package id without a new listing.

## Open Questions

- None blocking; passwords and alias are held only in local `key.properties`, not in this design.
