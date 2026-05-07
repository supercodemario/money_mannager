import 'package:drift/drift.dart';
import 'package:money_manager/data/local/app_database.dart';

class UserPreferencesRepository {
  UserPreferencesRepository(this._db);

  final AppDatabase _db;

  Stream<UserPreference?> watchForUser(String userId) {
    return (_db.select(_db.userPreferences)..where((t) => t.userId.equals(userId))).watch().map(
      (rows) => rows.isEmpty ? null : rows.first,
    );
  }

  Future<UserPreference?> getForUser(String userId) {
    return (_db.select(_db.userPreferences)..where((t) => t.userId.equals(userId))).getSingleOrNull();
  }

  Future<void> upsertForUser({
    required String userId,
    required String currencyCode,
    required String languageCode,
    required String numberFormat,
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final existing = await getForUser(userId);
    if (existing == null) {
      await _db.into(_db.userPreferences).insert(
            UserPreferencesCompanion.insert(
              userId: userId,
              currencyCode: Value(currencyCode),
              languageCode: Value(languageCode),
              numberFormat: Value(numberFormat),
              updatedAt: now,
            ),
          );
      return;
    }
    await (_db.update(_db.userPreferences)..where((t) => t.userId.equals(userId))).write(
      UserPreferencesCompanion(
        currencyCode: Value(currencyCode),
        languageCode: Value(languageCode),
        numberFormat: Value(numberFormat),
        updatedAt: Value(now),
      ),
    );
  }
}
