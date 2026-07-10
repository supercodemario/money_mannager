## Why

The project structure already mandates `auto_route`, but the app still navigates with imperative `Navigator` + `MaterialPageRoute`. That leaves two navigation styles, empty `routes/` folders, and incomplete `bootstrap_exports.dart`. Migrating now gives one consistent page-navigation system and aligns the codebase with the documented architecture.

## What Changes

- Add `auto_route` (and codegen) and introduce a root `AppRouter` wired through `MaterialApp.router`.
- Annotate all route-level screens with `@RoutePage`, register them via feature `routes/` + a central registry, and export them from `lib/bootstrap_exports.dart`.
- **BREAKING (internal):** Replace every page-level `Navigator.push` / `MaterialPageRoute` with typed auto_route navigation. Project policy: **one page-navigation style only** (`auto_route`).
- Keep `AppShell` bottom nav as `IndexedStack` (tabs are not AutoTabsRouter in this change).
- Keep `HouseholdFlowNavigation` / `ProfileDetailsNavigation` as composition-root facades; implementations must call auto_route only.
- Preserve typed return values for scan / join-confirm / post-login sync flows.
- Leave `showDialog` / `showModalBottomSheet` as Flutter modals (not page routes).
- Out of scope: deep links, auth route guards, web URL strategy, AutoTabsRouter.

## Capabilities

### New Capabilities
- `app-navigation`: Sole page-navigation system using `auto_route` (router setup, route registration, push/pop with results, ban on imperative page routes).

### Modified Capabilities
- *(none)* — bottom-nav and household UX requirements stay the same; only the navigation mechanism changes.

## Impact

- Dependencies: `auto_route`, `auto_route_generator`, `build_runner`.
- App bootstrap: `RegionalMaterialAppRoot` / `main.dart` switch from `home:` to `routerConfig`.
- ~12 files with `MaterialPageRoute` and ~15–18 screens gain `@RoutePage` + route modules.
- Nav facades under `lib/app/` and `lib/core/navigation/`.
- Widget tests that pump `MyApp` / assume `home:` may need router setup.
