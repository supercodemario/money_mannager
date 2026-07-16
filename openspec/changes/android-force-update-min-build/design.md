## Context

HomeRatio is a Flutter app with Android `applicationId` `com.nexkind.homelybudget`. Versioning already flows from `pubspec.yaml` (`version: x.y.z+build`) into Android `versionName` / `versionCode`. Supabase is initialized early via `CloudSyncController` using the anon key. There is no runtime force-update check today.

Product decision (explore): **hard-only** force update when local Android build &lt; remote minimum. Defaults for unresolved forks: **cached fail-open**, **Android-only**, check on **cold start and resume**.

## Goals / Non-Goals

**Goals:**

- Compare installed Android build number to a Supabase-configured minimum.
- Block the app with a non-dismissible update UI when below minimum.
- Deep-link / open Play Store for `com.nexkind.homelybudget`.
- Cache last successful policy so brief offline periods still enforce known mins.
- Fail open if never fetched a policy (avoid bricking installs when Supabase is down on first launch).

**Non-Goals:**

- Soft “update available” prompts.
- iOS App Store force update.
- Google Play In-App Updates API.
- Blocking based on marketing version string alone.
- Syncing force-update state as user/household data.

## Decisions

### 1. Comparator: Android `versionCode` (Flutter build number)

- **Choice**: Use `PackageInfo.buildNumber` parsed as int (= Android `versionCode`).
- **Why**: Play Store uniqueness and monotonicity; matches ops bump process.
- **Alternatives**: Semver `versionName` (error-prone ordering); store version only (no remote kill switch).

### 2. Remote source: single Supabase policy row (anon read)

- **Choice**: Table e.g. `app_version_policy` with at least:
  - `platform` text (`android`)
  - `min_build` int
  - `store_url` text (Play details URL)
  - `message` text (optional UI copy)
  - `updated_at` timestamptz  
  RLS: `SELECT` for `anon` and `authenticated` (public read-only). No client writes.
- **Why**: Already on Supabase; must work before login.
- **Alternatives**: Edge Function (extra deploy); Remote Config (new vendor).

### 3. Check timing: cold start + resume

- **Choice**: Run check after Supabase init on launch; re-check on `AppLifecycleState.resumed`.
- **Why**: Catches policy bumps while app was backgrounded.
- **Alternatives**: Cold start only (simpler, slower to enforce).

### 4. Offline / error: cached fail-open

- **Choice**: Persist last successful `{min_build, store_url, message}`. On fetch error: if cache exists, compare against cache; if no cache, allow app.
- **Why**: Avoid locking everyone out when network/Supabase fails; still enforce after at least one successful fetch.
- **Alternatives**: Fail closed (harsh); ignore cache (weaker).

### 5. UX: full-screen hard gate

- **Choice**: Dedicated route/overlay with title, message, primary “Update” CTA → Play Store. No close / back dismiss. Root navigation cannot proceed past the gate while outdated.
- **Why**: Matches hard-only product choice.
- **Alternatives**: Dialog (easier to dismiss accidentally); kill process (bad UX).

### 6. Feature placement

- **Choice**: Small module under `lib/features/force_update/` (or `app_version`) with data (remote + cache), model, and view; orchestrate from app shell / root wrapper after `AppServices` exists so Supabase client is available.
- **Why**: Matches feature folder rules; keeps shell thin.
- **Alternatives**: Inline in `main.dart` (harder to test).

### 7. Dependencies

- **Choice**: `package_info_plus` for build number; `url_launcher` for Play Store URL (add if not present).
- **Why**: Standard Flutter packages.

### 8. Ops sequence

- **Choice**: Document: ship Play build with new `versionCode` → wait until available → then raise `min_build` in Supabase. Never raise `min_build` above what Play currently serves.
- **Why**: Prevents users being forced to an unavailable build.

## Risks / Trade-offs

- **[Risk] Raise min_build before Play propagates** → Users stuck on update screen with no installable build. → Ops checklist; optionally keep `min_build` one release behind latest.
- **[Risk] Anon table abuse / scraping** → Public integers only; no secrets. Acceptable.
- **[Risk] Fail-open on first launch never online** → Rare; accept for v1.
- **[Risk] Resume check flashes content then gate** → Prefer gate overlay above shell; run check before interactive content when possible on cold start.
- **[Trade-off] Hard-only** → No soft nudge for optional updates; deferred.

## Migration Plan

1. Create Supabase table + RLS; seed `min_build` to current production `versionCode` (or `1`) so nobody is forced until ops raises it.
2. Ship app with force-update client.
3. Rollback client: previous builds ignore table (harmless). Rollback policy: lower `min_build` in Supabase.

## Open Questions

- Exact table/column names vs existing Supabase naming conventions in repo migrations (align during apply).
- Whether message copy is remote-only or falls back to `AppStrings` when empty (recommend: remote if non-empty, else `AppStrings`).
