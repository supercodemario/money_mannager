import 'package:flutter_test/flutter_test.dart';
import 'package:money_manager/data/local/sync_metadata_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('persists default expense household id', () async {
    expect(await SyncMetadataStore.getDefaultExpenseHouseholdId(), isNull);

    await SyncMetadataStore.setDefaultExpenseHouseholdId('household-1');
    expect(
      await SyncMetadataStore.getDefaultExpenseHouseholdId(),
      'household-1',
    );

    await SyncMetadataStore.clearDefaultExpenseHouseholdId();
    expect(await SyncMetadataStore.getDefaultExpenseHouseholdId(), isNull);
  });
}
