import 'package:drift/drift.dart';
import 'package:money_manager/core/logging/app_log.dart';
import 'package:money_manager/data/local/app_database.dart';
import 'package:money_manager/share/tokens/app_strings.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

class UserProfileRepository {
  UserProfileRepository(this._db);

  final AppDatabase _db;

  /// Supabase Auth `user_metadata` key for the in-app profile display name.
  static const authMetadataDisplayNameKey = 'display_name';

  static String? _currentAuthUserIdOrNull() {
    try {
      return Supabase.instance.client.auth.currentUser?.id;
    } catch (e, st) {
      logAppError('user_profile.current_auth_user_id', e, st);
      return null;
    }
  }

  /// Links the sole local profile to [authUserId] when signed in and [remote_id] is still null.
  Future<void> linkPrimaryProfileToAuthIfNeeded() async {
    final authId = _currentAuthUserIdOrNull();
    if (authId == null) return;

    final rows = await _db.select(_db.userProfiles).get();
    final alreadyLinked = rows.any((r) => r.remoteId == authId);
    if (alreadyLinked) return;

    if (rows.length == 1) {
      final only = rows.single;
      if (only.remoteId == null) {
        final now = DateTime.now().millisecondsSinceEpoch;
        await (_db.update(_db.userProfiles)..where((t) => t.id.equals(only.id))).write(
          UserProfilesCompanion(
            remoteId: Value(authId),
            updatedAt: Value(now),
          ),
        );
      }
    }
  }

  /// Resolves [expenseAuthUserId] (Supabase `auth.users` id from `expenses.auth_user_id`) to a local
  /// [user_profiles] row id for [Expenses.createdByUserId].
  Future<String> resolveProfileIdForExpenseAuthor(String expenseAuthUserId) async {
    await linkPrimaryProfileToAuthIfNeeded();

    final authId = _currentAuthUserIdOrNull();
    if (authId != null && expenseAuthUserId == authId) {
      return getCurrentUserId();
    }

    final existing =
        await (_db.select(_db.userProfiles)
              ..where((p) => p.remoteId.equals(expenseAuthUserId)))
            .getSingleOrNull();
    if (existing != null) return existing.id;

    final id = const Uuid().v4();
    final now = DateTime.now().millisecondsSinceEpoch;
    await _db.into(_db.userProfiles).insert(
          UserProfilesCompanion.insert(
            id: id,
            displayName: AppStrings.expenseHouseholdMemberDisplayName,
            createdAt: now,
            updatedAt: now,
            remoteId: Value(expenseAuthUserId),
          ),
        );
    return id;
  }

  Future<UserProfile> getCurrentProfile() async {
    await linkPrimaryProfileToAuthIfNeeded();

    final authId = _currentAuthUserIdOrNull();
    final rows = await _db.select(_db.userProfiles).get();
    if (rows.isEmpty) {
      throw StateError('No user profile');
    }

    if (authId != null) {
      for (final r in rows) {
        if (r.remoteId == authId) {
          return r;
        }
      }
    }

    final withoutRemote = rows.where((r) => r.remoteId == null).toList();
    if (withoutRemote.length == 1) {
      return withoutRemote.single;
    }
    if (rows.length == 1) {
      return rows.single;
    }

    rows.sort((a, b) => a.createdAt.compareTo(b.createdAt));
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
    await _pushDisplayNameToAuth(displayName);
  }

  /// Writes [displayName] to Supabase Auth `user_metadata` when signed in.
  Future<void> _pushDisplayNameToAuth(String displayName) async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return;
      await Supabase.instance.client.auth.updateUser(
        UserAttributes(data: {authMetadataDisplayNameKey: displayName}),
      );
    } catch (e, st) {
      logAppError('user_profile.push_display_name_auth', e, st);
      // Offline or Supabase not initialized — local name still saved.
    }
  }

  /// Copies `user_metadata.display_name` from the current session into the local
  /// primary profile (e.g. after sign-in or local DB wipe).
  Future<void> hydrateDisplayNameFromAuthSession() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return;
      final raw = user.userMetadata?[authMetadataDisplayNameKey];
      if (raw is! String) return;
      final name = raw.trim();
      if (name.isEmpty) return;

      final primary = await getCurrentProfile();
      if (primary.displayName == name) return;

      final now = DateTime.now().millisecondsSinceEpoch;
      await (_db.update(_db.userProfiles)..where((t) => t.id.equals(primary.id))).write(
        UserProfilesCompanion(
          displayName: Value(name),
          updatedAt: Value(now),
        ),
      );
    } catch (e, st) {
      logAppError('user_profile.hydrate_display_name_auth', e, st);
      // Supabase not ready or no session.
    }
  }
}
