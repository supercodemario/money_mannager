## Why

Cloud sync and expense rows are household-scoped, but users without a shared family still need a stable `household_id` for local and remote data. Today membership can be empty, so sync and pre-logout flows hit impossible states. A **personal (self) household** created at sign-up, plus an explicit **default expense household** preference, aligns product behavior with the data model and removes implicit `.limit(1)` guessing.

## What Changes

- Auto-provision a **personal household** when a user completes **cloud sign-up** (and backfill for existing signed-in users missing one), with the user as owner.
- Add **Settings / preferences**: choose **default household for new expenses and sync scope** among `{ personal household } ∪ { households the user belongs to }`. Default selection is **personal** when it is the only option.
- **Family list** may show the personal household like other rows, but **no QR**, **no invite**, and **no share** entry points for that row.
- **Household flows**: cannot invite into the personal household; cannot join or accept invite targeting a personal household (client gating + server enforcement).
- **Data model**: distinguish personal vs shared households (e.g. `households.kind` or `is_personal`) so UI and RPCs can enforce rules consistently.
- Resolve **active sync household** from persisted preference when valid; fall back to personal if shared membership is lost.

## Capabilities

### New Capabilities

- `personal-household-expense-scope`: Personal household lifecycle (auto-create on signup, backfill), default household preference, and rules that personal households never participate in invite/QR/join flows.

### Modified Capabilities

- `supabase-phase1-sync`: Household resolution for sync shall use the stored default expense household when the user is still a member; personal household is a valid sync target; pre-logout sync only when household-scoped sync is possible.
- `household-family-details`: Family list shows personal household without QR/invite affordances; opening members for personal household follows product rules (likely owner-only solo list).
- `household-flow-features`: Scan/join/invite/QR flows must reject or hide personal household as a target; RPC/migrations enforce non-membership expansion for personal kind.
- `settings-compact-screen`: Preferences details (reachable from the Preferences card) SHALL include default expense household selection alongside regional preferences.

## Impact

- **Supabase**: New migration(s) for `households` kind/personal flag; RPC or trigger for `ensure_personal_household` on signup; RLS/triggers so `join`/`invite` cannot attach users to personal households except self-owner path.
- **Flutter**: `CloudSyncController` / `SyncMetadataStore` or new preference store; `ensureHouseholdIfNeeded` replacement or augmentation; auth sign-up and join-family flows; family list + QR + settings UI; logout/account flows.
- **Existing users**: Migration or lazy creation of personal household on next session.
