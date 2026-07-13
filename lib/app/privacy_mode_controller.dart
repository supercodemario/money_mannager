import 'package:flutter/foundation.dart';
import 'package:money_manager/data/local/privacy_mode_preferences.dart';

/// Loads and updates the persisted Privacy mode flag for Settings ↔ Home.
class PrivacyModeController {
  PrivacyModeController();

  final ValueNotifier<bool> enabled = ValueNotifier<bool>(false);

  Future<void> load() async {
    enabled.value = await PrivacyModePreferences.isEnabled();
  }

  Future<void> setEnabled(bool value) async {
    await PrivacyModePreferences.setEnabled(value);
    enabled.value = value;
  }

  void dispose() {
    enabled.dispose();
  }
}
