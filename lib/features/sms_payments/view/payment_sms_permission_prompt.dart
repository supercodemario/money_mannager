import 'dart:io';

import 'package:flutter/material.dart';
import 'package:money_manager/app/app_services.dart';
import 'package:money_manager/core/logging/app_log.dart';
import 'package:money_manager/features/sms_payments/data/sms_payments_repository.dart';
import 'package:money_manager/features/sms_payments/models/payment_sms_state/payment_sms_state.dart';
import 'package:money_manager/share/share.dart';

/// Shows the SMS explain dialog + system permission on Android Home launch.
///
/// Independent of tutorial vs expense dashboard — does not require a first expense.
Future<void> promptSmsPermissionIfNeeded(BuildContext context) async {
  if (!Platform.isAndroid) return;

  final repo = SmsPaymentsRepository();
  final smsRead = AppServices.of(context).smsRead;
  try {
    final phase = await repo.resolvePhase();
    if (phase != PaymentSmsPermissionPhase.needsExplain) return;
    if (!context.mounted) return;

    final allow = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text(AppStrings.paymentSmsExplainTitle),
        content: const Text(AppStrings.paymentSmsExplainBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(AppStrings.paymentSmsExplainNotNow),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(AppStrings.paymentSmsExplainAllow),
          ),
        ],
      ),
    );

    await repo.markExplainDone();
    if (allow == true) {
      final granted = await repo.requestSmsPermission();
      await smsRead.setEnabled(granted);
    } else {
      await smsRead.setEnabled(false);
    }
  } catch (e, st) {
    logAppError('payment_sms.launch_permission', e, st);
  }
}
