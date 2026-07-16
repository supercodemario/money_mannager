import 'package:shared_preferences/shared_preferences.dart';

/// Device-local SMS payment prefs (not synced).
class SmsPaymentsPreferences {
  SmsPaymentsPreferences._();

  static const _explainDoneKey = 'sms_payments_explain_done';
  static const _handledKeysKey = 'sms_payments_handled_keys';
  static const _readEnabledKey = 'sms_payments_read_enabled';

  /// True after the user has seen the explain dialog (Allow or Not now).
  static Future<bool> isExplainDone() async {
    final p = await SharedPreferences.getInstance();
    return p.getBool(_explainDoneKey) ?? false;
  }

  static Future<void> setExplainDone(bool value) async {
    final p = await SharedPreferences.getInstance();
    await p.setBool(_explainDoneKey, value);
  }

  /// User preference to use Payment SMS on Home. Default false until granted once.
  static Future<bool> isReadEnabled() async {
    final p = await SharedPreferences.getInstance();
    return p.getBool(_readEnabledKey) ?? false;
  }

  static Future<void> setReadEnabled(bool value) async {
    final p = await SharedPreferences.getInstance();
    await p.setBool(_readEnabledKey, value);
  }

  static Future<Set<String>> handledKeys() async {
    final p = await SharedPreferences.getInstance();
    final list = p.getStringList(_handledKeysKey) ?? const [];
    return list.toSet();
  }

  static Future<void> markHandled(String key) async {
    final p = await SharedPreferences.getInstance();
    final list = p.getStringList(_handledKeysKey) ?? <String>[];
    if (list.contains(key)) return;
    list.add(key);
    await p.setStringList(_handledKeysKey, list);
  }
}
