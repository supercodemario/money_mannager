# Money Manager

## About this project

**Money Manager** is a cross-platform **Flutter** application for **personal and household money tracking**. The product experience is branded **homeRatio**: a bottom-tab shell (**Home**, **Expenses**, **Insights**, **Settings**) focused on daily spending, recurring bills, and gentle spending guidance (limits and summaries are **guidance**, not hard blocks).

### What it does today

- **Home** — Dashboard-style overview and shortcuts (including quick add).
- **Expenses** — Browse and manage expenses by day and month, including **recurring payment** templates and occurrences.
- **Insights** — Navigation slot is present; main content is still a **placeholder** pending future analytics UX.
- **Quick add** — Fast expense capture (amount, category, note).
- **Limits & preferences** — User-set expense limits and regional/preferences-style settings from **Settings** (see feature modules under `lib/features/`).
- **Categories** — Manage expense categories used across flows.
- **Cloud sync (optional)** — After signing in with Supabase Auth, eligible expenses can sync to Postgres under a **household** model (phase 1); without credentials the app stays **fully local**.

### Technical stance

- **Local-first:** All core data is stored on-device with **Drift** (SQLite). Nothing requires the network for basic expense tracking.
- **Privacy-conscious:** Cloud sync is opt-in via configuration; phase 1 sync scope is documented in **`docs/backend-developer-overview.md`**.
- **Specifications:** Product behaviour for larger features is captured in **`openspec/specs/`** and past work in **`openspec/changes/archive/`** (see **OpenSpec** below).

### Platform support

The codebase targets standard **Flutter** mobile/desktop platforms supported by the SDK (see `pubspec.yaml` and platform folders **`android/`**, **`ios/`**, etc.).

## Requirements

- [Flutter](https://docs.flutter.dev/get-started/install) (Dart SDK **^3.11** — see `pubspec.yaml`)
- For cloud sync: a Supabase project and applied SQL migrations

## Run the app

```bash
flutter pub get
flutter run
```

### With Supabase (cloud sync)

Credentials are passed at **compile time** (do not commit real keys):

```bash
flutter run \
  --dart-define=SUPABASE_URL=https://YOUR-PROJECT.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=YOUR_ANON_KEY
```

1. Copy `supabase.env.example` for local reference only.
2. Apply SQL from `supabase/migrations/` in the Supabase SQL editor — see **`docs/supabase_dev_setup.md`**.
3. Without these defines, the app runs **fully offline**; Settings shows that cloud sync is not configured.

### Backend / API notes

Phase 1 uses **Supabase PostgREST** against Postgres (no separate custom REST server). For schema, RLS, and client contracts, see **`docs/backend-developer-overview.md`**.

## Project layout (`lib/`)

| Path | Role |
|------|------|
| `lib/features/` | Screens and feature modules (auth, expenses, settings, …) |
| `lib/core/` | Shared infrastructure |
| `lib/data/` | Local DB (Drift), repositories, remote gateways |
| `lib/sync/` | Sync orchestration when cloud is enabled |
| `lib/share/` | Design tokens, shared widgets |

Architecture rules for contributors: **`.cursor/rules/project_structure.mdc`**.

## Testing

```bash
flutter test
```

## Documentation

| Doc | Purpose |
|-----|---------|
| `docs/supabase_dev_setup.md` | Create a dev Supabase project, keys, run migrations |
| `docs/backend-developer-overview.md` | Handoff for backend: tables, RLS, sync behaviour |

## OpenSpec (proposals, specs, and change workflow)

This repo uses **OpenSpec** for structured feature work: **what** to build (proposal), **how** (design), **requirements** (spec deltas), and **checklists** (tasks). The **openspec** CLI is available in this environment; source-of-truth requirements for the product live under **`openspec/specs/`**. Per-change work and history live under **`openspec/changes/`** and **`openspec/changes/archive/`**.

### Directory layout

| Path | Purpose |
|------|---------|
| `openspec/specs/<capability>/spec.md` | **Current** normative requirements (the “main” spec tree). |
| `openspec/changes/<change-name>/` | **Active** change: `proposal.md`, `design.md`, `tasks.md`, optional `specs/…` deltas, `.openspec.yaml`. |
| `openspec/changes/archive/YYYY-MM-DD-<change-name>/` | **Completed** changes, moved here when you archive. |

### CLI (quick reference)

```bash
openspec list --json              # active changes
openspec status --change "<name>" --json
```

Use the same commands in CI or local shells where `openspec` is installed.

### Cursor slash commands (this workspace)

In **Cursor** chat, these map to the workflow (see **`.cursor/commands/`** for full text):

| Command | Role |
|---------|------|
| **`/opsx-explore`** | Think through a problem, compare options, investigate the codebase — **no implementation** (explore / discovery). |
| **`/opsx-propose <name or description>`** | Create a new change: scaffold **`openspec/changes/<name>/`** and fill **proposal**, **design**, **spec** deltas, **tasks** (one-shot generation). |
| **`/opsx:apply <name?>`** | **Implement** from an active change’s `tasks.md` (code + mark tasks done). |
| **`/opsx-archive <name?>`** | **Finish** a change: optional spec sync into `openspec/specs/`, then **move** the folder to `openspec/changes/archive/…`. |

Agent skills for the same steps live under **`.cursor/skills/`** (e.g. `openspec-propose`, `openspec-apply-change`, `openspec-archive-change`, `openspec-explore`).

### Typical flow

1. **Explore** — Use **`/opsx-explore`** (or ad-hoc discussion) to clarify the problem and constraints.
2. **Propose** — Run **`/opsx-propose my-feature-name`** so artifacts exist under `openspec/changes/my-feature-name/`.
3. **Implement** — Run **`/opsx:apply`** (optional change name) and complete **`tasks.md`**.
4. **Merge specs** — When a change updates behaviour at the requirement level, merge its delta into **`openspec/specs/…`** as part of closing out the work (often coordinated during **`/opsx-archive`**).
5. **Archive** — Run **`/opsx-archive`** (optional change name) to move the finished change into **`openspec/changes/archive/`** and keep **`openspec list`** clean.

This workflow is optional for tiny edits, but it keeps larger changes reviewable and traceable for humans and agents alike.

## Learn Flutter

If you are new to Flutter:

- [Install Flutter](https://docs.flutter.dev/get-started/install)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter documentation](https://docs.flutter.dev/)
