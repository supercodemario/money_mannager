## Context

`locked-daily-pace` shipped write-once Pace snapshots using divisor `daysAfterToday = D − dayOfMonth`. Product doc `docs/daily-plan-and-pace.md` and user-validated examples require divisor **days left including today** so Pace answers “what can I spend **today**?”

## Goals / Non-Goals

**Goals:**

- Align Pace write formula with the doc.
- Fix last-day Pace = leftover (not 0).
- Update specs, tests, and doc implementation note.
- Keep Daily plan, locking, over-pace UI, and snapshot persistence.

**Non-Goals:**

- Renaming UI labels (Daily plan / Pace).
- Backfilling or rewriting existing snapshot rows for past dates.
- Cloud sync of pace history.
- Changing spendable pool or Daily plan formulas.

## Decisions

### 1. Divisor = days left including today

```text
daysLeftIncludingToday = max(0, D − dayOfMonth + 1)
Pace = max(0, pool − spentBeforeToday) ~/ daysLeftIncludingToday
  when daysLeftIncludingToday > 0 and leftover > 0; else 0
```

- **Why:** Matches “how much can I spend today”; if user spends Pace each day, Pace stays stable (examples in chat).
- **Replace:** `daysAfterToday = D − day`.

### 2. Column naming

- **Choice:** Prefer adding/using a clear calculator API `daysLeftIncludingToday`. Keep Drift column `days_after_today` storing the **divisor used at write** (now including-today count) to avoid a noisy rename migration, **or** rename column to `days_left_including_today` in the same schema bump if low cost.
- **Default for implement:** rename only in calculator/API comments first; migrate column name if tasks allow a clean schema bump.

### 3. Existing today’s snapshot

- **Choice:** Do not update today’s already-written row (immutability preserved). New formula applies on next ensure for dates without a row (tomorrow onward, or fresh installs).
- **Optional:** out of scope to delete today’s row to force recompute.

## Risks / Trade-offs

- **[Risk]** Users who already have today’s snapshot keep old Pace until tomorrow. → **Mitigation:** Accept; document in tasks verify note.
- **[Risk]** Specs in main `expense-limits` still describe exclude-today from older archive. → **Mitigation:** This change’s delta MODIFIED requirements become source of truth at archive sync.

## Migration Plan

1. Change calculator + ensure path + tests.
2. Optional schema comment/rename.
3. Update `docs/daily-plan-and-pace.md` implementation note to “aligned.”

## Open Questions

- None — product examples confirmed include-today divisor.
