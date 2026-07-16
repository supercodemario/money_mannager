import 'dart:io';

import 'package:permission_handler/permission_handler.dart';
import 'package:money_manager/features/sms_payments/data/sms_inbox_reader.dart';
import 'package:money_manager/features/sms_payments/data/sms_payments_preferences.dart';
import 'package:money_manager/features/sms_payments/models/parsed_payment_sms/parsed_payment_sms.dart';
import 'package:money_manager/features/sms_payments/models/payment_sms_state/payment_sms_state.dart';

/// Loads India payment SMS candidates and manages local handled keys / permission UX state.
class SmsPaymentsRepository {
  SmsPaymentsRepository({
    SmsInboxReader? inboxReader,
  }) : _inbox = inboxReader ?? SmsInboxReader();

  final SmsInboxReader _inbox;

  static const maxVisible = 8;

  bool get isAndroid => Platform.isAndroid;

  Future<PaymentSmsPermissionPhase> resolvePhase() async {
    if (!isAndroid) return PaymentSmsPermissionPhase.denied;

    final status = await Permission.sms.status;
    if (status.isGranted) return PaymentSmsPermissionPhase.granted;

    final explainDone = await SmsPaymentsPreferences.isExplainDone();
    if (!explainDone) return PaymentSmsPermissionPhase.needsExplain;
    return PaymentSmsPermissionPhase.denied;
  }

  Future<void> markExplainDone() => SmsPaymentsPreferences.setExplainDone(true);

  Future<bool> requestSmsPermission() async {
    final result = await Permission.sms.request();
    return result.isGranted;
  }

  Future<bool> openSystemSettings() => openAppSettings();

  Future<List<ParsedPaymentSms>> loadCandidates() async {
    if (!isAndroid) return const [];
    final status = await Permission.sms.status;
    if (!status.isGranted) return const [];

    final raw = await _inbox.readRecent();
    final parsed = parsePaymentCandidates(raw);
    final handled = await SmsPaymentsPreferences.handledKeys();
    final filtered = parsed.where((p) => !handled.contains(p.key)).toList();
    if (filtered.length <= maxVisible) return filtered;
    return filtered.take(maxVisible).toList(growable: false);
  }

  Future<void> markHandled(String key) => SmsPaymentsPreferences.markHandled(key);
}
