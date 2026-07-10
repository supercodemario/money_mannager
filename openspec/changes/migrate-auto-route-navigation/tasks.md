## 1. Dependencies and router skeleton

- [x] 1.1 Add `auto_route`, `auto_route_generator`, and `build_runner` to `pubspec.yaml`
- [x] 1.2 Create root `AppRouter` with `AppShell` as the initial route and a `RouteRegistry` aggregation point
- [x] 1.3 Update `RegionalMaterialAppRoot` to use `MaterialApp.router` / `routerConfig` (preserve locale + `RegionalFormattingScope`)
- [x] 1.4 Wire `AppRouter` from `main.dart` / `MyApp` and confirm cold start still shows the shell

## 2. Annotate screens and feature routes

- [x] 2.1 Add `@RoutePage` to all full-screen screens that are pushed today (shell overlays, settings, expenses, auth, family, profile)
- [x] 2.2 Add feature `routes/` modules that declare those pages and register into `RouteRegistry`
- [x] 2.3 Export every `@RoutePage` screen from `lib/bootstrap_exports.dart`
- [x] 2.4 Run `build_runner` and fix codegen until `AppRouter` compiles

## 3. Migrate composition-root facades

- [x] 3.1 Rewrite `AppHouseholdFlowNavigation` to use typed auto_route pushes (including `String?` / `bool?` results)
- [x] 3.2 Rewrite `AppProfileDetailsNavigation` to use typed auto_route push
- [x] 3.3 Keep QR dialog on `showDialog` (not a page route)

## 4. Replace remaining page navigations

- [x] 4.1 Migrate `AppShell` Quick Add push to auto_route
- [x] 4.2 Migrate settings / preferences / recurring / limits / category navigations to auto_route
- [x] 4.3 Migrate expenses and monthly category detail navigations to auto_route
- [x] 4.4 Migrate auth, post-login sync, logout sync, and account-session flow page pushes to auto_route
- [x] 4.5 Migrate dashboard and any other leftover `MaterialPageRoute` call sites
- [x] 4.6 Update route-page pops that return values to use auto_route pop APIs (leave dialog/sheet pops as-is)

## 5. Enforce single navigation style and verify

- [x] 5.1 Grep and remove all page-level `MaterialPageRoute` / imperative page `Navigator.push` usages
- [x] 5.2 Fix widget tests that assumed `MaterialApp(home: …)` to use the router
- [x] 5.3 Smoke-test tabs, Quick Add, settings subtree, expenses detail, auth/sync, and family create/scan/join/members
