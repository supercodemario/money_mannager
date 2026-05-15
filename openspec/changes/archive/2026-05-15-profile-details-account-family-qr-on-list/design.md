## Context

`ProfileDetailsScreen` currently renders display name plus a **personal** family-invite `QrImageView` (`profile_details_screen.dart`). **Compact Settings** embeds **`CloudSyncSettingsSection`** between the profile summary and the 2×2 card grid (`settings_screen.dart`). **Family list** already exposes **scan-to-join** (app bar and empty states) and **per-household “show QR”** (`family_list_screen.dart`). OpenSpec still tied add-member scanning to “the same contract as profile details,” which is obsolete once QR leaves profile details.

## Goals / Non-Goals

**Goals:**

- Spec and implementation align: profile details = **identity + cloud sync + account actions**; compact Settings = **no** standalone cloud sync card there; family list = **household QR + scan-to-join** (and downstream join/create flows).
- **Avatar**: reuse shared `MemberAvatar` (or equivalent) keyed by a **stable id** consistent with member rendering (e.g. Supabase `auth` user id when signed in with sync allowed, else local profile id—mirror previous QR payload rules for visual stability).
- **Sign out**: reuse the existing **sync-before-logout** and wipe path used from `auth_screen.dart` / `CloudSyncController` so behavior does not diverge.
- **Destructive action**: one entry point with **confirmation**; exact semantics (local-only reset vs Supabase user deletion) chosen to match product—if server-side delete is not yet implemented, ship **local teardown + sign out** behind the same UX label only if product agrees; otherwise gate behind “coming soon” is **non-goal**—prefer implementing one concrete path documented in tasks.

**Non-Goals:**

- Redesigning household RPCs or invite token formats (unless a gap is discovered during implementation).
- Moving household QR UI to a third surface beyond family list unless a defect forces it.

## Decisions

1. **Do not duplicate logout logic** — Extract or call a shared helper / navigation to the same `_signOut` / `SyncBeforeLogoutScreen` behavior as auth, rather than calling `signOut()` directly from profile details.
2. **Avatar id source** — Use the same string selection rules previously used for invite QR payload so avatars match roster glyphs and stay stable across display-name edits.
3. **Delete semantics (default recommendation)** — **Phase A**: “Delete” removes **local profile + session** and signs out, with strong copy if server account remains; **Phase B** (optional follow-up change): Supabase `deleteUser` / RPC if product requires full cloud account removal. Record the chosen phase in tasks during apply.
4. **Strings / tokens** — New copy for sign out, delete, confirmation, and remove QR-specific strings from profile details; keep or relocate family-invite hints only on family-list paths.
5. **Cloud sync card** — Reuse the existing `CloudSyncSettingsSection` widget (or extract a shared private layout used by both) embedded in `ProfileDetailsScreen`; remove it from `SettingsScreen` so there is a **single** place for sign-in / manage-account for cloud sync outside `AuthScreen`.

## Risks / Trade-offs

- **[Risk] Users looked for “my QR” under Settings → Profile** → **Mitigation:** Family entry in Settings already leads to list; ensure list empty state still exposes scan/create; optional one-line copy on profile details pointing to Settings → Family (product call).
- **[Risk] “Delete” interpreted as GDPR delete** → **Mitigation:** Dialog body states what is deleted (local vs cloud); spec requires confirmation, not a specific legal regime.
- **[Risk] Drift between auth logout and profile logout** → **Mitigation:** Single code path (shared method or service API).

## Migration Plan

1. Land spec deltas + implementation in one change (or apply in order: specs → code → archive).
2. Update widget tests that assert QR on profile details.
3. No server migration unless Phase B adds RPC.

## Open Questions

- **Delete semantics (resolved for v1):** **Phase A** — “Delete local data” runs `wipeLocalData` after confirmation; when a cloud session exists, the flow uses the same **sign-out + wipe** path as standard logout (`signOutWithSyncBeforeLogout` with optional sync gate). Server-side Supabase user deletion remains a possible future change.
