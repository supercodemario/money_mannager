## Context

The app shell (`AppShell`) hosts dashboard, expenses, insights placeholder, and settings with a shared bottom navigation bar. Showing onboarding inline on `DashboardHomeScreen` would couple tutorial UX to home metrics and future refactors. The product decision is to use a **dedicated route/screen** for “Get Started” and only mount the shell after the user completes or dismisses that flow.

Implementation exists under `AppShell` (onboarding gate + main shell), `GetStartedScreen`, and `OnboardingPreferences` (`shared_preferences`).

## Goals / Non-Goals

**Goals:**

- Gate the main shell until first-run onboarding is completed (per device install / prefs scope).
- Persist completion so repeat launches go straight to `AppShell`.
- Keep onboarding UI **out of** dashboard layout (no shared app bar with home unless explicitly desired later).
- Use existing design tokens and shared widgets where practical.

**Non-Goals:**

- **Changing bottom navigation styling or implementation** in `AppShell` (selection treatment, colors, icons, chip/tile affordances). Get Started work must not drive nav refactors; any nav redesign belongs in a separate change (e.g. `bottom-navigation` capability).
- Replacing or duplicating the **expense limits** domain model (onboarding may *mention* limits conceptually; limits remain under `expense-limits` capability).
- Product analytics and A/B testing of copy (unless added in a later change).
- Account-level sync of “completed onboarding” across devices (local prefs only unless requirements change).

## Decisions

1. **Local preference flag for completion**  
   - **Choice:** `SharedPreferences` (or platform equivalent) boolean `get_started_completed`.  
   - **Rationale:** Small, synchronous-enough read on cold start; no DB migration for transient UX state.  
   - **Alternative:** Column on user profile in SQLite — rejected as heavier than needed for a UI gate.

2. **Onboarding inside `AppShell` (single scaffold)**  
   - **Choice:** `AppShell` loads onboarding completion, shows `GetStartedScreen` as body when incomplete, and **always** builds the real bottom navigation bar (taps ignored until onboarding completes).  
   - **Rationale:** Users keep familiar shell chrome; avoids a root route with no bottom bar.  
   - **Alternative:** Separate `MaterialApp.home` for onboarding only — rejected because it hid the bottom navigation.

3. **Primary and secondary CTAs both mark complete**  
   - **Choice:** Both actions dismiss onboarding and show the shell (implementation may later route “Add first expense” to quick-add in one step).  
   - **Rationale:** Reduce friction; user intent is “done with intro” either way.  
   - **Alternative:** Force different outcomes — optional future enhancement.

4. **No fake bottom navigation on onboarding**  
   - **Choice:** Tutorial does not mimic `AppShell` tabs.  
   - **Rationale:** Prevents confusion between illustrative chrome and real navigation.

5. **Do not modify real bottom navigation styling for this change**  
   - **Choice:** Leave `_BottomNav` / `AppShell` bottom bar styling and selection logic untouched when implementing or reviewing Get Started.  
   - **Rationale:** Scope isolation; avoids regressions and mixed PR intent.  
   - **Alternative:** Bundle nav tweaks with onboarding — rejected.

## Risks / Trade-offs

- **[Prefs cleared]** → User may see onboarding again after OS/app data clear — acceptable for local-only flag.  
- **[Testing]** → Hard to test “first run” without clearing prefs — document dev reset or test override.  
- **[Upgrade from older builds]** → Users without the flag see onboarding once; acceptable default.

## Migration Plan

- Existing installs on first app update: first launch after update shows onboarding once if flag absent (treat unset as incomplete), unless product decides default-complete for upgrades — document if that changes.

## Open Questions

- Should **upgrade users** skip onboarding by default (`if app version first run`) vs net-new installs only?  
- Should **Settings** expose “Show Get Started again” to clear the flag?
