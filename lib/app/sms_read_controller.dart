import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:money_manager/features/sms_payments/data/sms_payments_preferences.dart';

/// Result of turning SMS read on from Settings.
enum SmsReadEnableResult {
  /// Feature enabled; SMS permission already granted or just granted.
  enabled,

  /// Opened the system app-settings screen so the user can grant SMS.
  openedAppSettings,

  /// System permission dialog was shown and the user denied it.
  denied,

  /// Not Android or feature turned off.
  skipped,
}

/// Persists the Settings “SMS read” toggle and coordinates Android permission.
class SmsReadController {
  SmsReadController();

  final ValueNotifier<bool> enabled = ValueNotifier<bool>(false);

  Future<void> load() async {
    if (!Platform.isAndroid) {
      enabled.value = false;
      return;
    }
    final prefOn = await SmsPaymentsPreferences.isReadEnabled();
    final granted = await Permission.sms.isGranted;
    // Stay in sync: preference on only counts when OS permission is granted.
    enabled.value = prefOn && granted;
    if (prefOn && !granted) {
      await SmsPaymentsPreferences.setReadEnabled(false);
    }
  }

  Future<void> setEnabled(bool value) async {
    await SmsPaymentsPreferences.setReadEnabled(value);
    enabled.value = value;
  }

  /// Turn feature off without touching OS permission.
  Future<void> turnOff() => setEnabled(false);

  /// Turn feature on from Settings: request SMS or open app settings if denied.
  Future<SmsReadEnableResult> turnOnFromSettings() async {
    if (!Platform.isAndroid) return SmsReadEnableResult.skipped;

    final status = await Permission.sms.status;
    if (status.isGranted) {
      await setEnabled(true);
      return SmsReadEnableResult.enabled;
    }

    // Previously denied / permanently denied → Android app permission screen.
    if (status.isPermanentlyDenied || await SmsPaymentsPreferences.isExplainDone()) {
      await SmsPaymentsPreferences.setExplainDone(true);
      await openAppSettings();
      return SmsReadEnableResult.openedAppSettings;
    }

    // First request from Settings.
    final result = await Permission.sms.request();
    await SmsPaymentsPreferences.setExplainDone(true);
    if (result.isGranted) {
      await setEnabled(true);
      return SmsReadEnableResult.enabled;
    }

    // Denied — open app settings so the user can enable SMS.
    await openAppSettings();
    return SmsReadEnableResult.openedAppSettings;
  }

  /// Call when returning to the app (e.g. from system settings).
  Future<void> refreshFromSystemPermission() async {
    if (!Platform.isAndroid) return;
    final granted = await Permission.sms.isGranted;
    if (granted) {
      await setEnabled(true);
    } else if (enabled.value) {
      await setEnabled(false);
    }
  }

  void dispose() {
    enabled.dispose();
  }
}
