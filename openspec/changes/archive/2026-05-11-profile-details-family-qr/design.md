## Context

The app stores a **single local user profile** with stable UUID `id` and `displayName` (`UserProfileRepository`, Drift). Compact Settings already loads `getCurrentProfile()` and supports renaming via dialog. **Family** flows are evolving; `family-expense-sync` remains roadmap/deferred, but the product needs a **client-side invite artifact** now: a QR another device can scan during “add to family.”

## Goals / Non-Goals

**Goals:**

- Ship a **Profile details** screen from Settings showing **display name** and a **QR code** suitable for **scan-to-add-to-family**.
- Define **v1 QR payload**: UTF-8 string equal to the **local profile `id`** (UUID). Scanners treat this as the invitee identifier until server-signed tokens exist.
- Reuse existing navigation patterns (`Navigator.push` + full-screen route, consistent with `PreferencesDetailsScreen`).
- Use **token-first UI** (spacing/colors/strings from `share/`).

**Non-Goals:**

- Implementing the **scanner UI**, **household membership APIs**, or Supabase rules for joining a family.
- **Avatar**, email, or multi-profile switching.
- Cryptographic signing or short-lived invite tokens (explicit **follow-up**).

## Decisions

| Decision | Choice | Rationale | Alternatives considered |
|----------|--------|-----------|-------------------------|
| QR generation | Add **`qr_flutter`** (render `QrImageView` from data) | Widely used, simple, fits Flutter | `barcode_widget`; custom painter (too much work) |
| Payload v1 | **Plain profile UUID string** | Matches today’s `UserProfile.id`; scanner can evolve to parse prefixed URIs later | `money_manager://invite?profileId=` — defer until deep-link handler exists |
| Entry UX | **Tappable profile card** (whole card or trailing chevron) opens Profile details; **Edit** remains for rename | Keeps spec promise of editing from Settings; drill-in for QR | Edit-only profile row — insufficient for QR discovery |
| Name editing on details | **Optional duplicate**: keep primary edit on Settings; details screen can show read-only name **or** reuse same dialog pattern | Avoids scope creep | Force all edits to details only — breaks current habit |

## Risks / Trade-offs

| Risk | Mitigation |
|------|------------|
| Plain UUID in QR is **identifying** if leaked | In-app helper copy: share only with trusted people; future signed invites |
| Repository assumption **`rows.first`** — single profile | Matches current app; multi-profile would change payload contract |
| Package adds binary size | Acceptable for one QR dependency |

## Migration Plan

- No DB migration. Deploy app update; old builds lack QR screen until upgraded.
- If v2 introduces signed tokens, scanners **SHOULD** accept v1 UUID-only payloads for backward compatibility during transition.

## Open Questions

- Exact **scanner** behavior on the other device (same change batch vs later).
- Whether **Family** summary card should eventually deep-link to household management vs profile QR (product).
