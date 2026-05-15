## 1. Supabase and ownership

- [x] 1.1 Add migration: ensure **owner** semantics (e.g. `household_members.role`, backfill one owner per existing household, first creator as owner for new households).
- [x] 1.2 Add **RPC** (or revised RLS + policy) allowing **owner** to insert another user into `household_members`; enforce **no duplicate** `(household_id, user_id)` (constraint + conflict handling).
- [x] 1.3 Define invitee resolution from scanned QR payload (mapping table or documented lookup); document and implement matching Dart gateway calling RPC.

## 2. Remote data and app wiring

- [x] 2.1 Implement repository/service methods: fetch household members for current `household_id`; detect **current user is owner**; call RPC with scanned payload after validation.
- [x] 2.2 Extend `ensureHouseholdIfNeeded` (or insert path) so the creating user’s membership row uses **`owner`** role where applicable.

## 3. UI — Family details screen

- [x] 3.1 Add scanner dependency + platform permissions (iOS/Android); implement scan route/modal for owners only.
- [x] 3.2 Build **Family details** screen: signed-in gate, member list, empty state, owner-only FAB or button for “Add member” (scan).
- [x] 3.3 Handle duplicate-member and error feedback from RPC.

## 4. Settings integration

- [x] 4.1 Wire **Family** summary card `onTap` to navigate to Family details (or ineligible UX per spec).
- [x] 4.2 Add strings/tokens for screen title, empty state, errors, “Already in family”, sign-in prompt.

## 5. Verification

- [ ] 5.1 Manual: signed-in owner lists members, scans invite QR, sees new member; duplicate scan shows message; non-owner cannot add.
- [x] 5.2 Analyzer + targeted tests (RPC gateway mocks / widget tests where feasible).
