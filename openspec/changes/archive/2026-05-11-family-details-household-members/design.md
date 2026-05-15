## Context

Supabase already models **households** and **household_members** (`user_id` → `auth.users`, `role` text). The client caches `household_id` after `ensureHouseholdIfNeeded()`. **Profile details** ships a QR whose payload is the **local** `UserProfile.id` (v1). Current RLS on `household_members` **insert** only allows `user_id = auth.uid()` (self-join), so an **owner adding someone else** cannot use a direct client insert under today’s policies — a **server-side function** (or revised policy) is required for the invitee’s row.

## Goals / Non-Goals

**Goals:**

- **Family details** screen: list members of the current household (signed-in, household id available).
- **Add member** for **household owner only**: camera **scan** of invitee’s QR; **idempotent** add (no duplicate rows).
- Wire **Settings → Family** card to this screen when the feature is available.
- Document **Supabase** changes: e.g. `role = 'owner'` for the creating user, **RPC** `add_household_member` (name TBD) that checks caller is owner in `household_id` and inserts `(household_id, invitee_auth_user_id, 'member')` (or appropriate role), with dedupe in SQL (`on conflict` / pre-check).

**Non-Goals:**

- Full **family-expense-sync** roadmap, push notifications, or local-only household without cloud.
- **Owner transfer** UI (can be a follow-up); design may note “owner fixed at household creation” unless we add transfer later.
- Resolving **display names** for arbitrary members if no profile API exists (placeholders or “Member” until profiles are synced).

## Decisions

| Topic | Decision | Rationale |
|-------|----------|-----------|
| Eligibility | **Signed-in** Supabase session required for Family details and scan-to-add | Aligns with product; household lives in Supabase. |
| Owner | User with `household_members.role = 'owner'` for the active household; **first** `ensureHouseholdIfNeeded` insert uses **`owner`**, later self-joins remain **`member`** unless changed by migration | Matches “QR holder = owner” when creator is the household creator; migration + backfill for existing rows TBD. |
| QR payload | **v1**: Keep compatibility with **profile QR** (UTF-8 string = local profile id). **RPC** maps invitee’s **local profile id** → **auth user id** via new table `profile_invite_keys(local_profile_id, auth_user_id, …)` **or** simpler v2: QR carries **auth user uuid** once profile screen is extended — **design spike** before implementation picks one. | Must bridge local QR to membership insert. |
| Scanner | Flutter package such as **mobile_scanner** (or team choice) + platform permissions | Standard pattern. |
| Dedup | RPC or insert with **UNIQUE (household_id, user_id)** + handle conflict → user message “Already in family” | DB-enforced + UX. |

## Risks / Trade-offs

| Risk | Mitigation |
|------|------------|
| RLS blocks owner inserting another user | **RPC** `security definer` + minimal grants; reviewed policies. |
| Local profile id in QR ≠ auth user without mapping | Mapping table or evolve QR to auth uuid when signed in; document in implementation tasks. |
| Existing households have no `owner` row | One-time migration: set **one** owner per household (e.g. earliest `user_id`). |

## Migration Plan

1. Deploy Supabase migration: `role` usage + RPC + optional mapping table.
2. Ship app with feature flag or version gate if needed.
3. Rollback: revert RPC + policies; app hides Family management if RPC missing.

## Open Questions

- Exact **RPC signature** and whether invitee must **accept** vs **instant add** after scan.
- **Display** for each row: email from auth vs anonymous id until profiles exist.
