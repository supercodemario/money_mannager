## Context

Dashboard Home (`DashboardHomeScreen` → `DashboardHomeExpenseBody`) shows budget hero, monthly spending, and upcoming bills. Expenses are created via Quick Add (bottom nav / FAB) or the regular `AddExpenseScreen` (amount, note, date, category grid)—neither accepts prefill args today.

The app has no SMS packages or `READ_SMS` permission. Device-local prefs already use SharedPreferences (`PrivacyModePreferences`, `OnboardingPreferences`) for non-synced UI state. Feature folders under `lib/features/` must stay isolated; cross-feature DTOs belong in `lib/core/` or `lib/share/`.

Product decisions (explore): Android only; always-on Home list; India debit/payment SMS only; prefill regular Add Expense; hide row after successful save; explain dialog before system permission; never sync SMS content.

## Goals / Non-Goals

**Goals:**

- Show a Payment SMS section on Home for Android users with SMS permission.
- Explain why SMS access is needed, then request runtime permission.
- Parse recent India payment/debit SMS into amount + note (+ date when available).
- Prefill regular Add Expense; user picks category and saves.
- Persist handled SMS keys locally so added items leave the list and do not reappear.
- Compile and run on iOS with the section omitted.

**Non-Goals:**

- iOS SMS reading or notification-listener workarounds.
- Syncing SMS bodies, senders, or handled keys to Supabase / Drift cloud paths.
- Auto-creating expenses without user confirmation.
- Credit/income SMS, OTPs, balance alerts, or promo SMS as expense candidates.
- Multi-country parsers beyond India (₹ / Rs / INR / UPI / common bank debit phrasing).
- Showing “Added” badges (v1 hides handled items entirely).
- Background SMS listener / real-time push of new messages into Home (refresh on Home visible / pull is enough for v1).

## Decisions

### 1. Feature module: `lib/features/sms_payments/`

- **Choice**: New feature with `data/`, `models/`, `bloc/`, `view/` (and `routes/` only if a dedicated screen is needed). Home embeds a private widget from this feature’s view layer, or a thin dashboard widget that depends on a repository exposed via `AppServices`.
- **Why**: Project structure requires feature folders; keeps SMS parsing and permission logic out of dashboard and add_expense.
- **Alternatives**: Stuff into `dashboard/` (mixes concerns); put parser in `core/` only (UI still needs a home for bloc/view).

### 2. Prefill without feature coupling

- **Choice**: Add optional `initialAmount`, `initialNote`, `initialDate` (and optional opaque `sourceSmsKey` for post-save callback) to `AddExpenseScreen`. Navigation uses existing shell/tab open-Add path or a small route/callback that passes a shared prefill DTO from `lib/share/` or `lib/core/` (e.g. `ExpensePrefill`).
- **Why**: Features must not import each other; SMS feature cannot import `add_expense` internals, and vice versa. Shared DTO + shell/orchestration is the isolation-safe path.
- **Alternatives**: Duplicate a SMS-specific add screen (rejected—diverges from regular flow); import add_expense from sms_payments (violates structure rules).

### 3. Android SMS package + permission

- **Choice**: Use a maintained Flutter SMS inbox package (e.g. `telephony` or equivalent that can query inbox) plus `permission_handler` (or the package’s own permission API). Declare `READ_SMS` in `android/app/src/main/AndroidManifest.xml`. Gate all inbox calls with `Platform.isAndroid`.
- **Why**: Inbox query is required for an always-on list; no first-party Flutter API.
- **Alternatives**: Notification listener (broader, harder); user paste-only (rejects product ask). Exact package locked at implementation after pub.dev compatibility check with current Flutter SDK.

### 4. Permission UX: explain dialog → system prompt

- **Choice**: First time the Home SMS section would load on Android, show an `AlertDialog` (token strings) describing: payment SMS on this device only, used to suggest expenses, never synced. Actions: **Not now** / **Allow**. Allow → system `READ_SMS` request. Persist “explained” / “not now” in SharedPreferences so the dialog does not spam every rebuild. Denied state shows a compact CTA to open settings or re-request when possible.
- **Why**: User asked for a proper details popup; mirrors family confirm dialogs; Play Store expectations for sensitive permissions.
- **Alternatives**: Jump straight to system prompt (opaque); ask at app launch (too aggressive).

### 5. India debit parser (heuristic v1)

- **Choice**: Pure-Dart parser in `sms_payments/data/` that:
  - Scans recent inbox messages (bounded window, e.g. last 14–30 days and/or last N messages).
  - Keeps candidates matching debit/spent/paid/UPI patterns and ₹/Rs/INR amounts.
  - Drops OTP, “available balance”, credit/credited/received (unless clearly not needed), and messages without a parseable amount.
  - Builds note from merchant/UPI counterparty snippet or truncated body.
- **Why**: India-only scope keeps heuristics manageable; false positives are worse than misses for trust.
- **Alternatives**: ML on-device (overkill); hardcode bank sender allowlists only (brittle across banks).

### 6. Handled state: SharedPreferences set of keys

- **Choice**: Stable key per message (prefer Android SMS id when available; else hash of address + date + body fingerprint). On successful expense save from SMS prefill, add key to local set and rebuild list filtered to exclude handled. No Drift table, no sync metadata.
- **Why**: Same pattern as privacy mode—device UI state, must not sync; simplest hide-after-add UX.
- **Alternatives**: Drift table (migration + sync risk); “Added” chip (deferred non-goal).

### 7. Home placement

- **Choice**: Payment SMS section directly under `DashboardMonthlySpendingCard`. Shown only when `Platform.isAndroid` and Home is in expense (not tutorial) mode. Hide the card when SMS permission is granted and the candidate list is empty.
- **Why**: Placement under monthly spending per product feedback; empty list should not take Home space.
- **Alternatives**: Under budget hero (initial design); always show empty state (rejected).

### 8. Refresh model

- **Choice**: Load/parse when Home expense body becomes visible and when returning from Add Expense after a successful SMS-sourced save. Optional pull-to-refresh if Home list already supports it; otherwise visibility + post-save is enough.
- **Why**: Avoid continuous SMS listeners and battery drain for v1.

## Risks / Trade-offs

- **[Risk] Play Store SMS policy** → Keep permission copy narrow (payment expense suggestions, on-device only); be prepared to document use-case; no SMS upload.
- **[Risk] Permission sheet + privacy peek** → Privacy mode clears on `paused`; system permission UI may trigger lifecycle. Prefer not tying SMS dialog to privacy reveal; accept brief privacy remask if it happens.
- **[Risk] Parser false positives/negatives** → Conservative debit filters; show only confidently parsed amounts; iterate patterns with real India SMS samples in tests.
- **[Risk] Feature isolation vs open Add tab** → Shell must accept prefill when switching to Add tab or push a dedicated Add Expense route with args; design handoff in implementation so sms_payments does not import add_expense.
- **[Risk] Duplicate expenses** → Handled keys prevent re-offer; user can still manually add the same spend—accepted.
- **[Trade-off] Android-only** → iOS users see no section; documented non-goal.
- **[Trade-off] No background listener** → New SMS may appear only after revisiting Home; acceptable for v1.

## Migration Plan

- New prefs keys default empty / never-asked → existing users see explain dialog once on Android Home.
- No schema migration.
- Rollback: remove Home section, permission, and package; leftover prefs keys are harmless.

## Open Questions

- Exact pub.dev SMS package after SDK compatibility check (implementation spike).
- Exact lookback window (14 vs 30 days) and max rows shown on Home (e.g. 5–10)—default proposal: last 14 days, max 8 visible with “no more” if empty after filter.
- Whether Add Expense stays as bottom-nav tab with injected prefill or a pushed route that pops back to Home—prefer whatever reuses existing save path with least shell churn.
