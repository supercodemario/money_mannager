## Context

The app uses **in-memory** expense entry (`QuickAddScreen`, `AddExpenseScreen`) with categories from `defaultExpenseCategories()`. There is **no** persistence layer yet (`pubspec.yaml` has no database packages). The user chose **Drift** for phase 1; **API integration is future work**.

The product direction includes **family expense tracking**: members on **other devices** can add or edit shared understanding of **daily / monthly** spend, with **sync** and unified views. Phase 1 still ships **local-only**, but the **schema and IDs** should anticipate **multi-writer sync** later.

## Goals / Non-Goals

**Goals:**

- Persist **user profile** data locally (at minimum: stable id, display name; room for future fields).
- Persist each **expense** with **integer minor-unit** amounts and a **foreign key to the creating user** (`created_by_user_id` or equivalent).
- **Bootstrap** exactly one local user on first launch (until family onboarding exists).
- Expose **repository-style APIs** for profile and expenses; Drift details stay out of widgets.
- Use **Drift** with migrations from day one.

**Non-Goals:**

- Remote API, **continuous sync**, OAuth, invites, or conflict-resolution **UI**.
- Full **family** management UI (multiple profiles on one device, roles)—may follow; schema should allow it.
- Full **Expenses** list UI, dashboard charts, or export (separate changes).

## Decisions

1. **Drift + SQLite**  
   - **Rationale:** Same as before; relational joins user ↔ expenses for reporting and future sync.

2. **Table `user_profiles` (phase 1)**  
   - **Purpose:** One row per **local member** the app knows about. Initially one row (current user).  
   - **Suggested columns:** `id` (TEXT PK, UUID), `display_name` (TEXT NOT NULL), optional `avatar_url` or `color_key` later nullable, `created_at`, `updated_at` (INTEGER UTC ms).  
   - **Optional later:** `household_id` (TEXT nullable, UUID) when **households** exist; add in a migration when family UX ships.

3. **Table `expenses` (phase 1)**  
   - **Columns:** `id` (TEXT PK, UUID), `amount_minor` (INTEGER), `currency_code` (TEXT), `category_id` (TEXT), `note` (TEXT nullable), `occurred_at`, `created_at`, `updated_at` (INTEGER UTC ms), **`created_by_user_id` (TEXT NOT NULL)** referencing `user_profiles.id`.  
   - **Rationale:** Every expense is attributable; future sync can filter or merge by member.

4. **Sync-oriented columns (recommended in v1 migration)**  
   - Add nullable: `remote_id` (TEXT), `sync_status` (TEXT enum as string: e.g. `pending`, `synced`, `conflict`), `server_updated_at` (INTEGER nullable) on **expenses** (and optionally **user_profiles**) so first sync change does not require a painful backfill.  
   - **Alternative:** Omit if the team wants the smallest possible v1 schema; accept a later migration that adds columns with defaults.

5. **Amounts as minor units**  
   - Unchanged.

6. **No `categories` table in v1**  
   - Unchanged.

7. **Repository abstraction**  
   - Split or namespace: `UserProfileRepository` + `ExpenseRepository` (or one facade)—implementation detail; widgets still depend on abstractions only.

8. **Future: households and sync (not implemented now)**  
   - **Household / family:** A future `households` (or `families`) table with `id` (UUID), `name`, `remote_id` nullable; **membership** table `household_members` (`household_id`, `user_profile_id`, `role`) when multi-user exists.  
   - **Sync:** Outbound/inbound deltas keyed by `remote_id` + vector clock or `updated_at` per row—**design in a later change**; this document only reserves IDs and optional columns.

## Risks / Trade-offs

| Risk | Mitigation |
|------|------------|
| Over-engineering v1 | Keep profile row count to **one** in UI; still model table for clean FK |
| Sync columns unused | Document as reserved; nullable; no background worker until sync change |
| Display name not collected | Bootstrap default “You” or prompt once—tasks decide |

## Migration Plan

- **v1:** `user_profiles` + `expenses` + indexes; seed one profile.  
- **Later:** Add `households` / membership, sync triggers, API—each as new Drift migration.

## Open Questions

- Default **display name** when user never opens settings (“Me”, “You”, device name?).  
- Whether **v1** includes nullable sync columns—**prefer yes** if this change implements schema in one go.

## Future architecture (family sync — reference)

```
┌──────────────┐     future API      ┌─────────────┐
│  Device A    │ ◄─────────────────► │  Backend    │
│  Drift DB    │                     │  (future)   │
└──────┬───────┘                     └──────▲──────┘
       │                                  │
       │         same household           │
       │                                  │
┌──────┴───────┐     future API      ┌────┴────────┐
│  Device B    │ ◄─────────────────► │             │
│  Drift DB    │                     │             │
└──────────────┘                     └─────────────┘
```

Local **Drift** remains source of truth offline; sync layer merges **expenses** (and later **profiles**/membership) using stable UUIDs and server ids in `remote_id`.
