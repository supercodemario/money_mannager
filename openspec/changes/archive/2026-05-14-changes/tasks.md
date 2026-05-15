## 1. Dependencies and contracts

- [x] 1.1 Add `bloc` and `flutter_bloc` to `pubspec.yaml` and run `dart pub get`
- [x] 1.2 Add `lib/core/navigation/household_flow_navigation.dart` defining `HouseholdFlowNavigation`
- [x] 1.3 Add `lib/app/household_flow_scope.dart` and `lib/app/household_flow_navigation_impl.dart` (concrete routes)
- [x] 1.4 Wrap `MyApp` child tree with `HouseholdFlowScope` + default `AppHouseholdFlowNavigation`

## 2. Feature modules (per screen)

- [x] 2.1 Create `family_list` feature (`bloc`, `data`, `models`, `view`, `routes`, `widgets`) with list + join-scan orchestration
- [x] 2.2 Create `family_members` feature with members load + owner add-member path via navigation contract
- [x] 2.3 Create `create_family` feature with invite registration / update / cancel flow
- [x] 2.4 Create `join_family_confirm` feature with accept-invite confirmation
- [x] 2.5 Create `household_scan` feature (scanner + paste sheet widget under `widgets/`)
- [x] 2.6 Create `household_qr_share` feature exposing the household QR share dialog entrypoint

## 3. Integration and cleanup

- [x] 3.1 Point Settings “Family” navigation to `family_list` feature `FamilyListScreen`
- [x] 3.2 Remove obsolete `lib/features/household` (or equivalent monolithic package) after parity
- [x] 3.3 Run `dart analyze` with zero issues; run `flutter test` for smoke tests that pump `MyApp` or scoped harnesses

## 4. Spec / product alignment

- [x] 4.1 Verify signed-in gating, owner-only add, join/invite, and duplicate-member UX still match `household-family-details` scenarios on device or manual QA checklist
