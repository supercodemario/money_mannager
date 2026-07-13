## Context

Home currently shows **Daily plan** (`pool ~/ D`) and a **live Pace / day** (`remaining ~/ daysAfterToday`) under monthly remaining. Live Pace includes today’s spend in remaining, so after overspending (e.g. Pace 500 → 200) users treat the new number as a fresh allowance. The product goal is stay-in-budget guidance: Pace must be a **locked daily target**, with exceed called out separately, and each day’s Pace kept in DB for analytics and future charts.

## Goals / Non-Goals

**Goals:**

- Write-once **Pace snapshot per local calendar day** (scoped like other local guidance: active user / expense scope used by limits).
- Snapshot formula at write time: `(pool − spentBeforeToday) ~/ daysAfterToday` (0 if remaining ≤ 0 or no days after today).
- Home shows **today’s spent vs locked Pace**, with over-Pace indication; Pace value does not change mid-day when expenses are added.
- Persist enough columns for later graphs (date key, pace minor, pool, spent-before-today, days-after-today, created-at).
- Align month day listing over/under with locked Pace when a snapshot exists for that day.

**Non-Goals:**

- Cloud sync / multi-device history for pace rows (local Drift only).
- Building charts/analytics UI in this change (storage + Home indication only).
- Changing Daily plan formula or monthly remaining/overspent math.
- Blocking expense saves when over Pace (still guidance-only).
- Backfilling historical Pace for days before this feature ships (optional best-effort only if cheap; not required).

## Decisions

### 1. Persist snapshots (A), compute with exclude-today spent (B) at write time

- **Choice:** On first ensure for local date `YYYY-MM-DD`, insert an immutable row; display always reads the row for today.
- **Why:** Analytics need a stable series; exclude-today at write avoids baking “already spent today” into the target when the day opens early, and still matches “don’t update by today” after the row exists.
- **Alternatives:** Live formula only (no history); SharedPreferences single-day cache (no multi-day analytics).

### 2. Immutability

- **Choice:** No updates to `paceMinor` (or snapshot inputs) for an existing date key. Re-ensure is a no-op if the row exists.
- **Why:** Prevents the 500→200 confusion and keeps charts honest if income/savings change later.
- **Note:** If limits were unset at first open then set later same day, product choice: allow insert only when limits become available and no row exists yet; still never overwrite.

### 3. Home UX

- **Choice:** Keep Daily plan + locked Pace under the monthly balance area (or adjacent daily expense / Pace pair). Show **today’s expense** next to locked Pace; when `spentToday > pace`, use over-budget styling / exceed amount—do **not** lower Pace.
- **Why:** Matches user mental model: “Am I within today’s Pace?” Monthly remaining can still update live separately.

### 4. Schema

- **Choice:** New Drift table e.g. `daily_pace_snapshots` with unique `(user_id, local_date)` (and household/scope key if expense limits are already scope-aware—match existing expense spent queries). Bump `schemaVersion` (currently 9 → 10) with create-table migration.
- **Columns (minimum):** `userId`, `localDate` (string `yyyy-MM-dd`), `paceMinor`, `poolMinor`, `spentBeforeTodayMinor`, `daysAfterToday`, `createdAtMs`.

### 5. Ensure timing

- **Choice:** Ensure today’s snapshot when derived limits stream emits with income configured (Home / repository watch path), not only on expense save.
- **Why:** Pace should exist for the day even if the user opens Home before spending.

### 6. Live `paceDailyMinor` helper

- **Choice:** Keep calculator helper for **writing** new snapshots and tests; Home UI MUST NOT show a continuously recomputed Pace for the current day.
- **Why:** Single formula definition; display path is DB-backed.

## Risks / Trade-offs

- **[Risk]** User changes income mid-day after snapshot → Pace stays old. → **Mitigation:** Acceptable; document as intentional. Tomorrow gets a new row. Optional future “regen today” is out of scope.
- **[Risk]** First open late in the day already overspent before today → snapshot may be low/zero. → **Mitigation:** Formula uses spent before today only; today’s overspend shows as exceed vs locked Pace, not as rewriting Pace.
- **[Risk]** Clock/timezone edge at midnight. → **Mitigation:** Use same local date keying as expenses (`monthKey` / local calendar day patterns already in app).
- **[Risk]** Listing vs Home inconsistency if listing stays on Daily plan only. → **Mitigation:** Prefer locked Pace for over/under when snapshot exists.

## Migration Plan

1. Add table + schemaVersion bump; empty table on upgrade.
2. Ship ensure-on-watch; first Home open after upgrade creates today.
3. No rollback of data required; dropping table on downgrade not supported (app forward-only).

## Open Questions

- None blocking: charts deferred; sync deferred; backfill not required.
