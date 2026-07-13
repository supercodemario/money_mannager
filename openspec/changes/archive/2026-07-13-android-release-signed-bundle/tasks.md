## 1. Local signing secrets

- [x] 1.1 Confirm `android/.gitignore` ignores `key.properties`, `*.jks`, and `*.keystore`
- [x] 1.2 Generate upload keystore at `android/homeratio-keystore.jks` (alias `homeRatio`) if it does not already exist; keep it local only
- [x] 1.3 Create gitignored `android/key.properties` with `storePassword`, `keyPassword`, `keyAlias`, and `storeFile` pointing at the keystore (do not commit)

## 2. Gradle release signing and package id

- [x] 2.1 Load `key.properties` in `android/app/build.gradle.kts` and define `signingConfigs.release` when the file exists
- [x] 2.2 Assign `signingConfigs.release` to `buildTypes.release` (stop using debug signing for release when properties are present)
- [x] 2.3 Set `applicationId` and `namespace` to `com.nexkind.homelybudget`; update MainActivity package/path if required for a clean build

## 3. Verify App Bundle

- [x] 3.1 Run `flutter build appbundle` and confirm a signed release `.aab` is produced
- [x] 3.2 Verify `git status` does not show `key.properties` or `*.jks` as tracked/staged files
