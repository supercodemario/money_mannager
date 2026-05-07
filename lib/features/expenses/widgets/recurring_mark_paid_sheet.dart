import 'package:flutter/material.dart';
import 'package:money_manager/data/repositories/recurring_payment_repository.dart';
import 'package:money_manager/features/expenses/widgets/expenses_amount_format.dart';
import 'package:money_manager/share/share.dart';

Future<void> showMarkRecurringPaidSheet(
  BuildContext context, {
  required RecurringPaymentRepository repo,
  required RecurringMonthRow row,
  required String monthKey,
}) async {
  final controller = TextEditingController(
    text: formatExpenseUsdMinor(row.template.amountMinorSuggested).replaceAll(r'$', ''),
  );
  var occurredAt = DateTime.now();

  final saved = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (ctx) {
      return StatefulBuilder(
        builder: (ctx, setModal) {
          return Padding(
            padding: EdgeInsets.only(
              left: AppSpacing.s16,
              right: AppSpacing.s16,
              top: AppSpacing.s8,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + AppSpacing.s16,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  AppStrings.recurringMarkPaid,
                  style: Theme.of(ctx).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: AppSpacing.s8),
                Text(
                  row.template.title,
                  style: Theme.of(ctx).textTheme.bodyMedium?.copyWith(color: AppColors.onSurfaceVariant),
                ),
                const SizedBox(height: AppSpacing.s16),
                TextField(
                  controller: controller,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: AppStrings.recurringConfirmAmountHint,
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: AppSpacing.s12),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text(AppStrings.dateLabel),
                  subtitle: Text(
                    '${occurredAt.year}-${occurredAt.month.toString().padLeft(2, '0')}-${occurredAt.day.toString().padLeft(2, '0')}',
                  ),
                  trailing: const Icon(Icons.calendar_today_outlined),
                  onTap: () async {
                    final d = await showDatePicker(
                      context: ctx,
                      initialDate: occurredAt,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (d != null) setModal(() => occurredAt = d);
                  },
                ),
                const SizedBox(height: AppSpacing.s16),
                FilledButton(
                  onPressed: () async {
                    final minor = parseUsdMinorFromString(controller.text);
                    if (minor == null || minor <= 0) {
                      ScaffoldMessenger.of(ctx).showSnackBar(
                        const SnackBar(content: Text('Enter a valid amount')),
                      );
                      return;
                    }
                    try {
                      await repo.markPaidForMonth(
                        recurringPaymentId: row.template.id,
                        monthKey: monthKey,
                        amountMinor: minor,
                        occurredAtLocal: occurredAt,
                      );
                      if (ctx.mounted) Navigator.of(ctx).pop(true);
                    } catch (e) {
                      if (ctx.mounted) {
                        ScaffoldMessenger.of(ctx).showSnackBar(
                          SnackBar(content: Text('$e')),
                        );
                      }
                    }
                  },
                  child: const Text(AppStrings.save),
                ),
              ],
            ),
          );
        },
      );
    },
  );

  controller.dispose();

  if (saved == true && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Payment recorded')),
    );
  }
}
