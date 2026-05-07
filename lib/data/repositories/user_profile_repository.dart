import 'package:drift/drift.dart';
import 'package:money_manager/data/local/app_database.dart';

class UserProfileRepository {
  UserProfileRepository(this._db);

  final AppDatabase _db;

  Future<UserProfile> getCurrentProfile() async {
    final rows = await _db.select(_db.userProfiles).get();
    return rows.first;
  }

  Future<String> getCurrentUserId() async {
    final p = await getCurrentProfile();
    return p.id;
  }

  Future<void> updateDisplayName(String displayName) async {
    final current = await getCurrentProfile();
    final now = DateTime.now().millisecondsSinceEpoch;
    await (_db.update(_db.userProfiles)..where((t) => t.id.equals(current.id))).write(
      UserProfilesCompanion(
        displayName: Value(displayName),
        updatedAt: Value(now),
      ),
    );
  }
}

