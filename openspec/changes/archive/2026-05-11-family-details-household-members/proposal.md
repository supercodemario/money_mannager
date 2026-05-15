## Why

Household membership already exists in Supabase (`households`, `household_members`), but the Settings **Family** entry is inert and users cannot see who is in their household or invite someone using the same QR story as profile details. Product rules agreed: **only signed-in users** use this flow; the **household owner** (aligned with who presents the profile invite QR) manages members; **duplicate membership** must be prevented.

## What Changes

- Add a **Family details** screen reachable from compact Settings **Family** summary card when the user is **signed in** (otherwise explain sign-in is required or hide/disable per UX decision in implementation).
- **List** current household members for the active synced household (membership backed by Supabase `household_members`).
- Add **“Add member”** via **camera QR scan** of another user’s invite payload (same encoding contract as profile-details family-invite QR or an evolved tokenized form defined in design).
- Enforce **owner-only** management: only the designated **owner** may access member management and scanning to add; non-owners get read-only or blocked UX per design.
- Enforce **no duplicate**: adding someone already in the household SHALL be rejected with clear feedback (no second insert).
- Likely **Supabase migration / RPC** (or policy updates): today’s RLS allows `household_members` insert only for `user_id = auth.uid()`, so inviting **another** user requires a server-side path (e.g. `security definer` RPC) — captured in design, not blocking the proposal.

## Capabilities

### New Capabilities

- `household-family-details`: Signed-in family details screen listing household members, owner-gated management, scan-to-add with deduplication, aligned with household membership in Supabase.

### Modified Capabilities

- `settings-compact-screen`: The **Family** summary card SHALL navigate to the family details experience when the capability is available (signed-in / household resolved); stub `onTap` removed at behavior level.

## Impact

- **UI:** `lib/features/settings/` — Family card navigation; new screen module under `settings` or `family/` per structure rules.
- **Data / remote:** Supabase queries for `household_members` (and possibly `households`); new RPC or migration for owner-invited inserts if required by RLS.
- **Dependencies:** QR/barcode camera package (e.g. `mobile_scanner` or equivalent), platform permissions.
- **Sync:** `SyncMetadataStore` / `CloudSyncController` household id; owner role persistence (may extend metadata or DB).
- **Related:** `profile-details-family-invite` QR payload contract — design must define mapping from scanned payload to `auth.users` / membership row.
