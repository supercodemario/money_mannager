import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money_manager/app/app_services.dart';
import 'package:money_manager/features/sms_payments/bloc/payment_sms_cubit.dart';
import 'package:money_manager/features/sms_payments/data/sms_payments_repository.dart';
import 'package:money_manager/features/sms_payments/models/parsed_payment_sms/parsed_payment_sms.dart';
import 'package:money_manager/features/sms_payments/models/payment_sms_state/payment_sms_state.dart';
import 'package:money_manager/share/share.dart';

/// Home Payment SMS card. Android-only; hidden when SMS read is off or list empty.
class PaymentSmsSection extends StatelessWidget {
  const PaymentSmsSection({
    super.key,
    required this.onAddToExpense,
    this.isActive = true,
  });

  /// Opens Add Expense; returns [ExpensePrefill.sourceKey] when save succeeds.
  final Future<String?> Function(ExpensePrefill prefill) onAddToExpense;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    if (!Platform.isAndroid) return const SizedBox.shrink();

    return ValueListenableBuilder<bool>(
      valueListenable: AppServices.of(context).smsRead.enabled,
      builder: (context, smsOn, _) {
        if (!smsOn) return const SizedBox.shrink();

        return BlocProvider(
          create: (_) => PaymentSmsCubit(SmsPaymentsRepository())..bootstrap(),
          child: _PaymentSmsSectionBody(
            onAddToExpense: onAddToExpense,
            isActive: isActive,
          ),
        );
      },
    );
  }
}

class _PaymentSmsSectionBody extends StatefulWidget {
  const _PaymentSmsSectionBody({
    required this.onAddToExpense,
    required this.isActive,
  });

  final Future<String?> Function(ExpensePrefill prefill) onAddToExpense;
  final bool isActive;

  @override
  State<_PaymentSmsSectionBody> createState() => _PaymentSmsSectionBodyState();
}

class _PaymentSmsSectionBodyState extends State<_PaymentSmsSectionBody> {
  @override
  void didUpdateWidget(covariant _PaymentSmsSectionBody oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.isActive && widget.isActive) {
      context.read<PaymentSmsCubit>().refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return BlocBuilder<PaymentSmsCubit, PaymentSmsState>(
      builder: (context, state) {
        final showList = state.phase == PaymentSmsPermissionPhase.granted &&
            !state.loading &&
            state.items.isNotEmpty;

        if (!showList) return const SizedBox.shrink();

        return AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings.paymentSmsSectionTitle,
                style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: AppSpacing.s12),
              ...state.items.map(
                (item) => _PaymentSmsRow(
                  item: item,
                  onAdd: () => _onAdd(item),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _onAdd(ParsedPaymentSms item) async {
    final handledKey = await widget.onAddToExpense(
      ExpensePrefill(
        amountMinor: item.amountMinor,
        note: item.note,
        date: item.occurredAt,
        sourceKey: item.key,
      ),
    );
    if (!mounted || handledKey == null || handledKey.isEmpty) return;
    await context.read<PaymentSmsCubit>().markHandled(handledKey);
  }
}

class _PaymentSmsRow extends StatelessWidget {
  const _PaymentSmsRow({
    required this.item,
    required this.onAdd,
  });

  final ParsedPaymentSms item;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final amount = RegionalFormattingScope.of(context).formatMinor(item.amountMinor);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.s12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  amount,
                  style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: AppSpacing.s4),
                Text(
                  item.note,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodySmall?.copyWith(color: AppColors.onSurfaceVariant),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.s8),
          TextButton(
            onPressed: onAdd,
            child: const Text(AppStrings.paymentSmsAddToExpense),
          ),
        ],
      ),
    );
  }
}
