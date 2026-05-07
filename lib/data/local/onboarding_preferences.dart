import 'package:shared_preferences/shared_preferences.dart';

/// Persists first-run onboarding state separate from domain data (e.g. expense limits).
class OnboardingPreferences {
  OnboardingPreferences._();

  /// SharedPreferences key. QA/dev: clear this (set to false or remove) to show
  /// Get Started again on next cold start—e.g. app settings → clear storage, or
  /// `adb shell` / iOS Simulator erase, or programmatic reset in debug builds.
  static const _getStartedCompletedKey = 'get_started_completed';

  static Future<bool> isGetStartedCompleted() async {
    final p = await SharedPreferences.getInstance();
    return p.getBool(_getStartedCompletedKey) ?? false;
  }

  static Future<void> setGetStartedCompleted() async {
    final p = await SharedPreferences.getInstance();
    await p.setBool(_getStartedCompletedKey, true);
  }
}
