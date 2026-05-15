# Supabase (dev) — phase 1

Use this when wiring local builds to a **development** Supabase project. Do not commit real keys.

## 1. Create a project

1. Open [Supabase Dashboard](https://supabase.com/dashboard) and create a project.
2. Pick a **region** close to your testers (set at creation time).
3. Wait until the project is **healthy** (Database + API ready).

## 2. Enable Auth

1. **Authentication → Providers**: enable **Email** (or your chosen provider for the pilot).
2. For dev, you may disable “Confirm email” under Auth settings to speed up testing (not for production).

## 3. Keys and URL

1. **Project Settings → API**: copy **Project URL** and **anon public** key.
2. Pass them to Flutter at compile time (see root `README` Supabase section), e.g.:

   ```bash
   flutter run --dart-define=SUPABASE_URL=https://xxxx.supabase.co --dart-define=SUPABASE_ANON_KEY=eyJ...
   ```

3. Never commit keys; use CI secrets for team builds.

## 4. Apply database SQL

1. **SQL Editor** in Supabase: paste and run the migration file from this repo: `supabase/migrations/20260417120000_phase1.sql`.
2. Confirm tables exist: `households`, `household_members`, `expenses` (and RLS enabled).
3. Create a test user under **Authentication → Users**, then verify policies with that user (optional SQL checks).

## 5. Smoke checklist (manual)

See OpenSpec task **6.2** in `openspec/changes/supabase-integration-phase1/tasks.md`.

## 6. Profile “Clear all data” (cloud purge RPC)

The app calls RPC **`cancel_all_my_family_invites`** before deleting other rows (clients cannot `SELECT` `family_invites` under RLS). Apply:

`supabase/migrations/20260515100000_cancel_all_my_family_invites.sql`

If this migration is missing, clearing signed-in data fails at the first RPC step until you run it on the project.
