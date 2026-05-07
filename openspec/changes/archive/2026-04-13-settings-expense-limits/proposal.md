## Why

Users need a structured way to translate **monthly income** into an **indicative daily spend amount** so the app can guide expectations without blocking transactions. The Limits grid card is currently inert; the home dashboard still shows **placeholder** budget numbers. This change introduces persisted inputs (income, optional savings, optional deduction for **unpaid, enabled** recurring obligations) and derived **guidance** values for the current local month.

## What Changes

- New **expense limits** flow: user enters **monthly income** (same currency minor units as expenses); the system derives a **monthly spendable pool** and an **indicative daily amount** using the **number of days in the current local calendar month**.
- Optional **monthly savings reservation** (fixed amount subtracted from income before spreading the remainder).
- Optional **exclude unpaid recurring**: subtract the sum of **suggested amounts** for recurring templates that are **scheduling-enabled** and **unpaid for that month** (per existing occurrence rules), then derive daily/monthly guidance from what remains.
- **Guidance only** in v1: the daily figure is an **indicator** of sustainable pace, not a hard cap; future work may add debit/credit-style variance on home.
- **Settings → Limits** summary card **navigates** to a dedicated limits detail screen (parity with Recurring).
- **Out of scope for v1:** a separate mode where users set daily/monthly caps **without** income; enforcement/blocking of spends; full home variance UI.

## Capabilities

### New Capabilities

- `expense-limits`: Persistence of income/savings/toggles; derivation of monthly pool and indicative daily amount; limits detail screen behavior; integration rules with recurring data (unpaid + enabled only); guidance semantics (non-blocking).

### Modified Capabilities

- `settings-compact-screen`: **Limits** summary card SHALL open the expense limits detail screen (today `onTap` is empty).

## Impact

- **Drift / local storage**: new table or structured storage for limit preferences (per profile if multi-profile later; v1 can follow existing single-profile pattern).
- **`RecurringPaymentRepository`** (read-only aggregation): sum **enabled** templates with **unpaid** occurrence for the **relevant month key** when the exclude option is on.
- **Settings UI**: wire Limits card; new screen under `lib/features/settings/` (or agreed feature folder).
- **Optional follow-up** (tasks may scope): replace static dashboard “daily limit” display with derived guideline when limits are configured—does not require a new top-level capability if treated as implementation detail of `expense-limits` consumption.
