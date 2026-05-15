import 'package:flutter_test/flutter_test.dart';
import 'package:money_manager/data/remote/household_remote_gateway.dart';

void main() {
  test('personal household is not shareable via model flags', () {
    const personal = HouseholdSummaryRow(
      householdId: 'id-personal',
      name: 'Self',
      myRole: 'owner',
      kind: HouseholdKind.personal,
    );
    const shared = HouseholdSummaryRow(
      householdId: 'id-shared',
      name: 'Family',
      myRole: 'owner',
      kind: HouseholdKind.shared,
    );

    expect(personal.isPersonal, isTrue);
    expect(shared.isPersonal, isFalse);
  });
}
