## 1. Dependencies and Supabase

- [x] 1.1 Add `package_info_plus` and `url_launcher` (if missing) to `pubspec.yaml` and run pub get
- [x] 1.2 Add SQL migration for `app_version_policy` (platform, min_build, store_url, message, updated_at) with anon/authenticated SELECT RLS
- [x] 1.3 Seed Android row with `min_build` ≤ current production `versionCode` and Play Store URL for `com.nexkind.homelybudget`

## 2. Data layer

- [x] 2.1 Scaffold `lib/features/force_update/` (`data/`, `models/`, `bloc/` or controller, `view/`, `routes/` as needed)
- [x] 2.2 Implement device-local policy cache (SharedPreferences) for min_build, store_url, message
- [x] 2.3 Implement Supabase reader for Android policy (anon-safe query)
- [x] 2.4 Implement resolver: fetch → update cache; on failure use cache; no cache → allow
- [x] 2.5 Implement local build reader via `PackageInfo` (Android build number as int)

## 3. Gate UX and navigation

- [x] 3.1 Add `AppStrings` (and tokens) for force-update title, default body, and Update CTA
- [x] 3.2 Build non-dismissible force-update screen with Update action opening Play Store URL
- [x] 3.3 Wire root/shell gate so outdated Android builds cannot reach normal Home content
- [x] 3.4 Register route (if using auto_route) and export in `bootstrap_exports.dart` as required

## 4. Lifecycle

- [x] 4.1 Run force-update check after Supabase init on cold start (Android only)
- [x] 4.2 Re-run check on `AppLifecycleState.resumed` (Android only)
- [x] 4.3 Skip entire capability on non-Android platforms

## 5. Verification

- [x] 5.1 Unit-test resolver: below min → force; equal/above → allow; fetch fail + cache → use cache; fetch fail + no cache → allow
- [x] 5.2 Manual Android: raise remote `min_build` above installed → gate + Play Store; lower again → app usable
- [x] 5.3 Document ops steps: ship Play build first, then raise `min_build` in Supabase
