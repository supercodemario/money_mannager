## Context

Navigation today is imperative (`Navigator` + `MaterialPageRoute`) from screens, widgets, and composition-root facades (`HouseholdFlowNavigation`, `ProfileDetailsNavigation`). `AppShell` hosts bottom tabs via `IndexedStack`; “Add” and other flows push full-screen routes. Project structure already requires `auto_route`, feature `routes/`, `RouteRegistry`, and `bootstrap_exports.dart`, but those pieces are incomplete.

Constraints:
- Features MUST NOT import other features; cross-feature navigation stays at the app composition root.
- Typed results matter for household scan (`String?`), join confirm (`bool?`), and post-login sync (`bool`).
- Regional locale wrapping lives in `RegionalMaterialAppRoot` (currently `MaterialApp` + `home:`).

## Goals / Non-Goals

**Goals:**
- Single page-navigation mechanism: `auto_route` only.
- Root `AppRouter` + `MaterialApp.router` with feature route modules registered centrally.
- Replace all page-level `MaterialPageRoute` usages.
- Preserve facade APIs so features stay isolated; facades call the router.
- Preserve modal dialogs/sheets as Flutter overlays.

**Non-Goals:**
- `AutoTabsRouter` / per-tab navigation stacks.
- Deep links, auth guards, web path strategy.
- Converting `showDialog` / `showModalBottomSheet` into routes.
- Changing bottom-nav UX or tab content.

## Decisions

### 1. IndexedStack shell + routed pushes (not AutoTabsRouter)
**Choice:** Keep `AppShell` as the home route with `IndexedStack` tabs; every full-screen push is an auto_route page.

**Why:** Matches current UX with less risk; still eliminates dual page-navigation styles.

**Alternative considered:** `AutoTabsRouter` — deferred; can follow once the router is stable.

### 2. Central `AppRouter` + feature route modules + registry
**Choice:** Each feature owns route definitions under `routes/`; modules register into a `RouteRegistry`; `AppRouter` aggregates them. All `@RoutePage` screens are exported from `lib/bootstrap_exports.dart` for codegen.

**Why:** Matches `PROJECT_STRUCTURE_SPEC` and keeps feature isolation.

**Alternative considered:** One monolithic `app_router.dart` listing every page — simpler short-term, fights the documented architecture.

### 3. Facades wrap auto_route (do not delete yet)
**Choice:** Keep `HouseholdFlowNavigation` / `ProfileDetailsNavigation`; `App*Navigation` implementations use `context.router` / typed routes (including `push` with result types).

**Why:** Cubits/features already depend on these seams; swapping the transport avoids a second cross-feature import wave.

**Alternative considered:** Call generated routes from features directly — would require features to know route types that reference other features’ pages, violating isolation.

### 4. One style enforcement
**Choice:** After migration, no page navigation via `Navigator.push` + `MaterialPageRoute`. `Navigator.pop` inside dialogs/sheets remains OK. Prefer `context.router.maybePop` / typed pop for route pages.

**Why:** User requirement: only one navigation type for pages.

### 5. `RegionalMaterialAppRoot` takes `routerConfig`
**Choice:** Change the root widget to accept `RouterConfig` / `AppRouter` instead of `home:`, preserving locale/`RegionalFormattingScope` `builder`.

**Why:** Locale streaming must stay outside the router; only the `MaterialApp` wiring changes.

### 6. Codegen workflow
**Choice:** `auto_route` + `auto_route_generator` + `build_runner`; regenerate after route/screen annotation changes.

## Risks / Trade-offs

- **[Risk] Broken typed results on family/auth flows** → Mitigation: migrate those call sites first with explicit result types; manual smoke test join/scan/sync.
- **[Risk] Feature isolation broken if screens import each other’s routes** → Mitigation: only `app/` router + facades reference cross-feature pages; features navigate via facades or own routes only.
- **[Risk] Widget tests fail after removing `home:`** → Mitigation: provide a test `AppRouter` / `MaterialApp.router` helper.
- **[Trade-off] IndexedStack tabs are not in the route graph** → Acceptable for v1; back button / deep link per tab not required yet.
- **[Trade-off] Registry + codegen is more boilerplate than a single file** → Aligns with project rules; Cursor can generate the boilerplate.

## Migration Plan

1. Add dependencies and empty `AppRouter` with `AppShell` as initial route; switch `MaterialApp.router`.
2. Annotate screens and add feature route modules; expand `bootstrap_exports.dart`; run codegen.
3. Replace facade implementations to use auto_route.
4. Replace remaining `MaterialPageRoute` call sites file by file.
5. Grep for `MaterialPageRoute` / page-level `Navigator.push` and clear leftovers.
6. Smoke-test: tabs, Quick Add, settings subtree, expenses detail, auth/sync, family create/scan/join/members.
7. Rollback: revert the change branch; no data migration involved.

## Open Questions

- None blocking — AutoTabsRouter explicitly deferred to a later change if needed.
