import 'package:shared_preferences/shared_preferences.dart';

/// Pilot metadata for cloud sync (household scope, pull watermarks).
class SyncMetadataStore {
  SyncMetadataStore._();

  static const _householdIdKey = 'sync_household_id';
  static const _lastExpensePullMsKey = 'sync_last_expense_pull_ms';
  static const _lastRecurringTemplatePullMsKey =
      'sync_last_recurring_template_pull_ms';
  static const _lastRecurringOccurrencePullMsKey =
      'sync_last_recurring_occurrence_pull_ms';
  static const _postAuthBootstrapDoneKey = 'sync_post_auth_bootstrap_done';

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

  static Future<int> getLastRecurringTemplatePullServerMs() async {
    final p = await SharedPreferences.getInstance();
    return p.getInt(_lastRecurringTemplatePullMsKey) ?? 0;
  }

  static Future<void> setLastRecurringTemplatePullServerMs(int ms) async {
    final p = await SharedPreferences.getInstance();
    await p.setInt(_lastRecurringTemplatePullMsKey, ms);
  }

  static Future<int> getLastRecurringOccurrencePullServerMs() async {
    final p = await SharedPreferences.getInstance();
    return p.getInt(_lastRecurringOccurrencePullMsKey) ?? 0;
  }

  static Future<void> setLastRecurringOccurrencePullServerMs(int ms) async {
    final p = await SharedPreferences.getInstance();
    await p.setInt(_lastRecurringOccurrencePullMsKey, ms);
  }

  static Future<bool> getPostAuthBootstrapCompleted() async {
    final p = await SharedPreferences.getInstance();
    return p.getBool(_postAuthBootstrapDoneKey) ?? false;
  }

  static Future<void> setPostAuthBootstrapCompleted(bool done) async {
    final p = await SharedPreferences.getInstance();
    await p.setBool(_postAuthBootstrapDoneKey, done);
  }

  static Future<void> clearAll() async {
    final p = await SharedPreferences.getInstance();
    await p.remove(_householdIdKey);
    await p.remove(_lastExpensePullMsKey);
    await p.remove(_lastRecurringTemplatePullMsKey);
    await p.remove(_lastRecurringOccurrencePullMsKey);
    await p.remove(_postAuthBootstrapDoneKey);
  }
}
