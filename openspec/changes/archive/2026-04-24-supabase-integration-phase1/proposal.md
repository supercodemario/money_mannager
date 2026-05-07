## Why

The app currently persists data **locally** (Drift) while **`family-expense-sync`** remains deferred. To support **shared households across devices** without premature or costly custom infrastructure, we will integrate **Supabase** (managed PostgreSQL + Auth) as the **first-phase** backend—sized for a **small pilot (roughly 5–15 members)** with a path to **self-hosted PHP + Postgres** later via standard SQL migrations.

## What Changes

- Add a **Supabase project contract** for the app: Auth session handling, secure client configuration, and networking assumptions for Flutter.
- Define **relational schema and Row Level Security (RLS)** for multi-member households and their data (minimal viable entities aligned with existing local models where possible).
- Implement **client integration** (`supabase_flutter`): initialization, lifecycle, and a thin abstraction so domain code does not hard-code SDK calls everywhere.
- Specify a **phase-1 sync strategy**: local-first remains default; upload/download reconciliation rules, idempotency, and conflict posture are documented (aligned with `family-expense-sync` goals).
- Enforce a **separate network module** for Supabase **data** I/O: **feature/UI code never calls remote APIs for domain sync**; only a **DB-driven sync orchestrator** (pending rows / outbox) triggers uploads and pulls.
- **No breaking change** to existing **offline-only** installs until sync is enabled by feature flag or explicit user sign-in; local Drift remains source of truth until sync is connected and merged per design.

## Capabilities

### New Capabilities

- `supabase-phase1-sync`: Supabase-backed auth, schema/RLS expectations, Flutter client bootstrap, and phase-1 sync behavior for a small household pilot.

### Modified Capabilities

- (None for this proposal.) Implementation binds to the existing **`family-expense-sync`** roadmap spec at the behavioral level; a separate follow-up change may **delta** that spec if normative requirements need to be tightened once sync ships.

## Impact

- **Dependencies**: `supabase_flutter`, Supabase dashboard (Auth, DB, RLS policies), environment/config for keys (no secrets in repo).
- **Flutter**: `main.dart` / app bootstrap, new `data` or `sync` layer modules, optional feature flags.
- **Security**: anon/service roles, RLS policies, and key handling documented in design; keys never committed.
- **Future**: PostgreSQL schema and migrations remain portable to **PHP/Laravel** or other hosts using standard Postgres tooling.
