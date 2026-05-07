## Why

Quick Add captures amount, date, note, and category, but nothing is persisted. Users need expenses stored on device so future features (monthly and daily views, category filters, charts) can read real data. A clear first phase keeps **all data local**; **remote API integration is explicitly deferred** to avoid blocking shipping a solid offline-first foundation.

**User and household vision:** Expenses should be attributable to a **person** (user / family member). The product direction includes **family expense tracking**: multiple members, multiple devices, and **shared visibility** of daily and monthly activity with **sync**—so the data model and IDs chosen now must not block a later **API + sync** change.

## What Changes

- Introduce **SQLite persistence via Drift** with tables for **expenses** and **local user profile(s)** (see design).
- Add a small **data layer** (database definition, migrations, repository API) consumed by feature code—not UI talking to Drift directly.
- **Bootstrap** a default local user profile on first launch (single-device, single “member” until family features ship).
- **Wire Quick Add** (and the full Add Expense flow when used) so a successful save **inserts** an expense row linked to the current user (UUID ids, amount in minor units, category id, note, `occurred_at`, timestamps).
- Add **dependencies** (`drift`, `drift_flutter`, `sqlite3_flutter_libs`, codegen dev deps) and **build_runner** for generated Drift code.
- **Out of scope for this change:** REST/GraphQL clients, **live sync**, push notifications, conflict resolution UI, **family invite / auth**, and UI for listing or charting expenses beyond what is needed to verify persistence (optional minimal test or debug path only if tasks require it). **Family sync** is captured in design and a roadmap spec for a **future** change.

## Capabilities

### New Capabilities

- `local-expense-storage`: Local-only persistence of expense rows (schema, insert path from app flows, query hooks for future reporting), including **association with a local user id**. API and sync are not part of this capability.
- `local-user-profile`: Persist **user details** needed for attribution and future family features (display name, stable local id; extensible fields per design). No remote account required in this change.

### Modified Capabilities

- *(none)* — Existing UI specs are not rewritten here; saving behavior is specified under the new capabilities.

### Roadmap (future change; not implemented here)

- `**family-expense-sync`**: Multi-device sync, multi-member updates, merged daily/monthly views—specified in `specs/family-expense-sync/spec.md` as **target behavior** for a later proposal; implementation is explicitly **not** in this change.

## Impact

- **Dependencies:** New packages (Drift stack, build_runner, drift_dev).
- **Code:** New `lib/` modules for database and repositories; optional onboarding or settings stub for **display name** if tasks require it; updates to Quick Add / save handlers.
- **Build:** Code generation step for Drift (`build_runner`).
- **Future:** UUIDs for users and expenses, repository boundary, and optional sync-oriented columns (per design) reduce migration pain when **family sync** ships.

