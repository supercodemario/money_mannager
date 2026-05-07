import 'package:shared_preferences/shared_preferences.dart';

/// Pilot metadata for cloud sync (household scope, pull watermarks).
class SyncMetadataStore {
  SyncMetadataStore._();

  static const _householdIdKey = 'sync_household_id';
  static const _lastExpensePullMsKey = 'sync_last_expense_pull_ms';

  static Future<String?> getHouseholdId() async {
    final p = await SharedPreferences.getInstance();
    return p.getString(_householdIdKey);
  }

  static Future<void> setHouseholdId(String id) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_householdIdKey, id);
  }

  static Future<void> clearHouseholdId() async {
    final p = await SharedPreferences.getInstance();
    await p.remove(_householdIdKey);
  }

  static Future<int> getLastExpensePullServerMs() async {
    final p = await SharedPreferences.getInstance();
    return p.getInt(_lastExpensePullMsKey) ?? 0;
  }

  static Future<void> setLastExpensePullServerMs(int ms) async {
    final p = await SharedPreferences.getInstance();
    await p.setInt(_lastExpensePullMsKey, ms);
  }

  static Future<void> clearAll() async {
    final p = await SharedPreferences.getInstance();
    await p.remove(_householdIdKey);
    await p.remove(_lastExpensePullMsKey);
  }
}
