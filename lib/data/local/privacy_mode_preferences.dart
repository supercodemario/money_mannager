import 'package:shared_preferences/shared_preferences.dart';

/// Device-local Privacy mode preference (not synced).
class PrivacyModePreferences {
  PrivacyModePreferences._();

  static const _enabledKey = 'privacy_mode_enabled';

  static Future<bool> isEnabled() async {
    final p = await SharedPreferences.getInstance();
    return p.getBool(_enabledKey) ?? false;
  }

  static Future<void> setEnabled(bool enabled) async {
    final p = await SharedPreferences.getInstance();
    await p.setBool(_enabledKey, enabled);
  }
}
