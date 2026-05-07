## 1. Project and dependencies

- [x] 1.1 Add `supabase_flutter` (and transient deps) to `pubspec.yaml` with versions compatible with the repo’s Flutter/Dart SDK
- [x] 1.2 Document Supabase **dev** project setup: create project, note region, enable Auth email (or chosen provider), copy anon URL/key for local builds only

## 2. Configuration and bootstrap

- [x] 2.1 Define compile-time or runtime injection for `SUPABASE_URL` and `SUPABASE_ANON_KEY` (e.g. `--dart-define`, flavor-specific config); add `.env.example` or README section **without real secrets**
- [x] 2.2 Initialize Supabase in app bootstrap (`main.dart` / root widget) with explicit handling when configuration is missing (safe disable path per spec)

## 3. PostgreSQL schema and RLS (Supabase SQL)

- [x] 3.1 Author SQL migration(s) for phase-1 tables: at minimum `households`, `household_members` (or equivalent), and synced entities aligned with local models (e.g. `expenses` foreign keys + `updated_at`)
- [x] 3.2 Enable RLS on all user-facing tables; implement policies so users read/write only rows for households they belong to
- [x] 3.3 Apply migrations to the Supabase dev project and verify with SQL console / test users *(operator: run `supabase/migrations/20260417120000_phase1.sql` in Supabase SQL Editor — see `docs/supabase_dev_setup.md`)*

## 4. Flutter Auth shell

- [x] 4.1 Implement sign-in / sign-out flow using Supabase Auth (minimal UI or reuse existing settings shell) behind a feature flag if required
- [x] 4.2 Persist and observe session state; expose to repositories whether sync is allowed

## 5. Sync layer (phase 1)

- [x] 5.0 Add a **remote-only** package path (e.g. `lib/data/remote/`) for Supabase **data** APIs; **forbid** imports of it from `lib/features/` (lint or `dependency_validator`-style check if available)
- [x] 5.0.1 Implement a **sync orchestrator** that subscribes to Drift **pending/outbox** state (or `watch` on `sync_status`) and is the **sole** invoker of remote upsert/pull for domain entities; UI saves **only** through repositories into Drift
- [x] 5.1 Introduce a thin `Supabase` data access layer (wrappers) so sync code does not scatter raw SDK calls; **no** feature widgets call this layer
- [x] 5.2 Map Drift entities to Supabase rows for in-scope tables; reuse existing `remote_id` / `sync_status` columns where present
- [x] 5.3 Implement push: pending local rows → upsert with idempotency (client UUID)
- [x] 5.4 Implement pull: incremental fetch since last cursor/watermark → merge into Drift per design (LWW)
- [x] 5.5 Add logging or row-level sync status for debugging pilot issues

## 6. Quality and verification

- [x] 6.1 Run `dart analyze` on touched packages
- [x] 6.2 Manual smoke test: cold start offline → record expense → go online + sign in → sync → second device sees data (pilot checklist)
