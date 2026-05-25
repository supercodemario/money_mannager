## Context

The app is local-first: repositories write to Drift with `sync_status` (`local_only`, `pending`, `synced`, `error`). `SyncOrchestrator` watches pending rows, debounces ~500ms, and today runs a **full** cycle: push profiles, recurring templates, expenses, occurrences, then pull all entity types. `CloudSyncController.syncAllowed` means Supabase is initialized and a session exists; it does **not** reflect OS network state. Failed pushes while offline can mark expenses `error` even though the device was simply unreachable.

## Goals / Non-Goals

**Goals:**

- After a logged-in user saves an expense, upload to Supabase **soon after save** when OS connectivity reports online (no pull on that path).
- When offline (per OS), keep expenses in **`pending`** without marking `error` solely for lack of connectivity.
- Retry expense upload when connectivity is restored or when new pending rows appear.
- Preserve **manual** sync as full **push-then-pull** for all phase-1 entities (post-login, settings, logout preflight).

**Non-Goals:**

- Supabase Realtime subscriptions or live multi-device awareness.
- Changing pull semantics for manual sync.
- Auto-upload of recurring payments, occurrences, or expense profile (they remain manual-cycle only).
- Replacing `error` for genuine server/validation failures during push when online.

## Decisions

1. **Two orchestrator entry points**
   - **`runAutoExpenseSync()`** — push pending **expenses** only; no pull; no profile/recurring push.
   - **`runManualSync()`** — unchanged full `pushThenPull` for all in-scope entities.
   - **Why:** Matches product intent (fast expense upload) without pull overhead on every save.
   - **Alternative:** Single cycle with flags; rejected as easy to call wrong path from UI.

2. **OS connectivity via `connectivity_plus`**
   - Auto push runs only when `syncAllowed` **and** OS reports a connected interface (not `none`).
   - **Why:** User explicitly chose OS signal over reachability probes.
   - **Alternative:** HEAD/ping Supabase; rejected for latency and complexity.

3. **Offline = skip push, keep `pending`**
   - Auto cycle returns before HTTP when offline; does **not** call `markRemoteError`.
   - **Why:** `pending` means “will upload when possible”; `error` reserved for failed attempts when online.
   - **Alternative:** Use `local_only` while offline; rejected because spec defines `local_only` for unsigned sessions.

4. **Auto cycle triggers**
   - Drift watch on `expenses` where `sync_status = pending` (existing pattern, debounced).
   - `CloudSyncController` listener when `syncAllowed` becomes true.
   - `connectivity_plus` `onConnectivityChanged` when transitioning to connected.
   - **Why:** Covers save, login, and reconnect without UI calling remote APIs.

5. **Serialized queue retained**
   - Both auto and manual sync enqueue on `_syncQueue` to avoid overlapping pushes.
   - **Why:** Prevents duplicate upserts and interleaved pull/push races.

6. **Background `_runCycle` uses auto path only**
   - `SyncOrchestrator.start()` debounced handler calls `runAutoExpenseSync()` instead of `runManualSync()`.
   - Manual screens continue calling `runManualSync()`.

## Risks / Trade-offs

- **[Risk] OS “connected” but Supabase unreachable** → Rows stay `pending`; next connectivity event or pending watch retries. Acceptable per product choice.
- **[Risk] Recurring/profile pending longer** → Documented; users sync via manual/post-login flows.
- **[Risk] Stale local view vs other devices** → No auto pull; user uses manual sync or post-login bootstrap for cloud data.
- **[Risk] `connectivity_plus` platform quirks** → Log connectivity transitions; test iOS/Android sim offline.

## Migration Plan

1. Add `connectivity_plus` dependency.
2. Implement `ConnectivityGate` (or inline helper) used by orchestrator auto path.
3. Split orchestrator APIs; point `SyncLifecycle` / pending watch at auto path.
4. Add tests; verify manual sync tests still use full cycle.
5. No Drift schema migration required.

## Open Questions

- Should auto push run `ensureDefaultExpenseHouseholdPreference()` before expense upsert (lightweight, likely yes for missing `household_id`)?
- Debounce interval: keep 500ms or shorten for snappier upload (implementation detail).
