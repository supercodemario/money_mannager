## Why

Existing users who already have expenses in Supabase can sign in on a device whose local database is empty and not immediately see their cloud data in local views. The current post-login flow is centered on `local_only` uploads, so there is no explicit user-driven bootstrap path that guarantees cloud-to-local hydration right after authentication.

## What Changes

- Add an explicit post-login bootstrap sync flow that prioritizes pulling Supabase expenses into local Drift storage for signed-in users.
- Ensure this flow runs even when there are zero `local_only` rows, so existing cloud data is linked into local state on first signed-in session for that device.
- Preserve the current local-first upload behavior for `local_only` rows, but orchestrate it with a clear stage order and user feedback.
- Add a reusable manual sync entry point for authenticated users to trigger cloud-to-local refresh on demand.
- Improve sync observability for post-login bootstrap failures and retries.

## Capabilities

### New Capabilities

- `post-login-cloud-bootstrap-sync`: Guarantees an explicit post-auth bootstrap path to pull existing Supabase data into local storage, with user-visible progress and retry behavior.

### Modified Capabilities

- `supabase-phase1-sync`: Expand post-login/manual sync requirements so cloud-to-local pull is explicitly supported for existing users even when no `local_only` rows are present.

## Impact

- Affected code: auth flow screens, sync orchestrator/manual sync entry points, sync metadata handling, and related UI copy.
- Affected behavior: post-login navigation and manual sync UX for signed-in users.
- Risk areas: duplicate merge handling, sync stage ordering (pull vs push), and first-login timing/race conditions.