# Daily plan & Pace — product concepts

> **Purpose of the app:** guide the user to hit their **monthly spending / saving goal**.
>
> UI **labels may change**; the **concepts and behavior** below should stay the same.

---

## Context

Users typically have:

- **Salary / monthly income** (fixed for the month in practice)
- **Recurring payments** (predefined bills — rent, EMI, etc.)
- **Saving plan** (amount they intend to set aside)

From those, the app derives a **spendable pool** for the month (income minus savings minus unpaid recurring when that option is on). Guidance is **non-blocking**: we advise; we do not block expenses.

---

## Daily plan

**What it is:**  
How much the user can spend **per day** if they spread the month’s spendable pool evenly across every day of the month.

**Idea:**  
At the start of the month (or whenever limits are set), given salary, recurring payments, and savings, answer:

> “If I spend about the same every day, what’s my daily amount?”

**Formula (concept):**

```text
Daily plan = spendable pool ÷ days in month
```

**Properties:**

- Does **not** change when the user spends more or less on a given day
- Is the month’s **baseline** “even pace” guide
- Name in the UI may change (e.g. “Daily budget”, “Plan / day”); functionality stays the same

---

## Pace (working name)

**What it is:**  
After real life happens — some days over Daily plan, some under — how much the user can still spend **today** so they can stay on track for the **rest of the month** with a fixed salary/pool.

**Why it exists:**  
If the user overspends on day X, they **cannot** keep using the same Daily plan amount forever: that money is already gone and income is fixed. The app must **recalculate** a realistic “what can I spend from here?” amount.

**Idea:**  
Each calendar day, calculate once:

> “Given what’s already spent before today, how much can I spend **today** (and keep a sustainable amount for the remaining days)?”

**Formula (concept):**

```text
leftover for today onward = spendable pool − spent before today

Pace = leftover for today onward ÷ days left including today
```

Where `days left including today` = days from today through the last day of the month.

**Properties:**

- Recalculated **once per calendar day** (new day → new Pace)
- **Do not** live-update Pace when the user adds expenses **during** the same day (that confuses people into thinking they have a new smaller “allowance” to spend again)
- Compare **today’s spend** to today’s Pace → on track / over Pace (indication only)
- Persist each day’s Pace for history, analytics, and charts
- Name in the UI may change (e.g. “Adjusted daily”, “Today’s limit”, “Stay-on-track”); concept stays the same

---

## Side by side

| | Daily plan | Pace |
|--|------------|------|
| Question | Fair share for every day this month? | What can I spend **today** to stay on track after past days? |
| Uses past spend? | No | Yes (spent **before** today) |
| Changes mid-day when user spends? | No | No |
| New value next calendar day? | Same (unless pool/limits change) | Yes (recalculated) |
| UI name | May change | May change |

---

## User guidance story

1. Set income, savings, recurring → see **Daily plan** (even month guide).
2. Live the month: some days over, some under.
3. Each morning, see **Pace** = how much is sensible **today** given money already used.
4. If today goes over Pace → show clear over indication; **do not** shrink Pace mid-day.
5. Tomorrow → new Pace from updated leftover and fewer days left.

---

## Implementation note

Pace is stored once per local calendar day in Drift (`daily_pace_snapshots`) for Home stability and analytics.

**Aligned with this doc:** Pace write formula is

```text
(pool − spent before today) ÷ days left including today
```

(`D − dayOfMonth + 1`). The row is not updated mid-day when the user spends. The DB column `days_after_today` stores that include-today divisor (historical column name).
