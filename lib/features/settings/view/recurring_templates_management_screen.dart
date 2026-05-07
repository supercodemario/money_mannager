import 'package:flutter/material.dart';
import 'package:money_manager/app/app_services.dart';
import 'package:money_manager/data/local/app_database.dart'
    hide ExpenseCategory;
import 'package:money_manager/data/remote/sync_constants.dart';
import 'package:money_manager/features/add_expense/data/default_expense_categories.dart';
import 'package:money_manager/features/add_expense/models/expense_category/expense_category.dart';
import 'package:money_manager/features/expenses/view/add_recurring_payment_screen.dart';
import 'package:money_manager/features/expenses/widgets/expenses_amount_format.dart';
import 'package:money_manager/features/auth/view/post_login_cloud_sync_screen.dart';
import 'package:money_manager/share/share.dart';
import 'package:money_manager/sync/sync_orchestrator.dart';

class RecurringTemplatesManagementScreen extends StatelessWidget {
  const RecurringTemplatesManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final recurring = AppServices.of(context).recurring;
    final categoryById = {for (final c in defaultExpenseCategories()) c.id: c};

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.recurringManageScreenTitle),
        actions: [
          if (AppServices.of(context).cloudSync.syncAllowed)
            IconButton(
              tooltip: AppStrings.cloudSyncRefreshCloudData,
              icon: const Icon(Icons.cloud_sync_outlined),
              onPressed: () => _openRecurringCloudSync(context),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push<void>(
            MaterialPageRoute<void>(
              builder: (context) => const AddRecurringPaymentScreen(),
            ),
          );
        },
        tooltip: AppStrings.recurringAddTitle,
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        elevation: AppSpacing.s4,
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<List<RecurringPayment>>(
        stream: recurring.watchAllTemplates(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('${snapshot.error}'));
          }
          final list = snapshot.data ?? [];
          if (list.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.s24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      AppStrings.recurringEmptyTitle,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s8),
                    Text(
                      AppStrings.recurringEmptySubtitle,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.s16),
            itemCount: list.length,
            separatorBuilder: (context, index) =>
                const SizedBox(height: AppSpacing.s8),
            itemBuilder: (context, index) {
              final t = list[index];
              final cat = categoryById[t.categoryId];
              return AppCard(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.s12,
                  AppSpacing.s8,
                  AppSpacing.s12,
                  AppSpacing.s4,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      minLeadingWidth: AppSpacing.s48,
                      horizontalTitleGap: AppSpacing.s12,
                      titleAlignment: ListTileTitleAlignment.titleHeight,
                      leading: _CategoryLeadingIcon(category: cat),
                      title: Text(
                        t.title,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      subtitle: Text(
                        '${AppStrings.recurringDueEachMonthSummary(t.dayOfMonth)} · ${formatExpenseUsdMinor(t.amountMinorSuggested)}'
                        '${t.endMonthKey != null ? ' · ${AppStrings.recurringEndsInMonth(t.endMonthKey!)}' : ''}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                      trailing: Semantics(
                        label: AppStrings.recurringManageScheduledSwitchLabel,
                        toggled: t.isEnabled,
                        child: Switch.adaptive(
                          value: t.isEnabled,
                          onChanged: (v) =>
                              recurring.setSchedulingEnabled(t.id, v),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: OverflowBar(
                        spacing: AppSpacing.s4,
                        children: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).push<void>(
                                MaterialPageRoute<void>(
                                  builder: (context) =>
                                      AddRecurringPaymentScreen(
                                        editingTemplateId: t.id,
                                      ),
                                ),
                              );
                            },
                            child: const Text(
                              AppStrings.recurringManageEditAction,
                            ),
                          ),
                          TextButton(
                            onPressed: () =>
                                _showDeleteRecurringTemplateDialog(context, t),
                            child: Text(
                              AppStrings.recurringDelete,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.error,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

Future<void> _showDeleteRecurringTemplateDialog(
  BuildContext context,
  RecurringPayment template,
) async {
  final ok = await showDialog<bool>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: const Text(AppStrings.recurringDeleteConfirmTitle),
        content: Text(AppStrings.recurringDeleteConfirmBody(template.title)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text(AppStrings.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text(AppStrings.recurringDelete),
          ),
        ],
      );
    },
  );
  if (ok != true || !context.mounted) return;
  await AppServices.of(context).recurring.deleteTemplate(template.id);
}

Future<void> _openRecurringCloudSync(BuildContext context) async {
  final services = AppServices.of(context);
  final unsynced = await services.recurring.countUnsynced();
  final localOnly = await services.recurring.countBySyncStatuses({
    SyncStatusValue.localOnly,
  });
  final localRows = await services.recurring.countAllRows();
  if (!context.mounted) return;
  final mode = unsynced > 0
      ? ManualSyncMode.pushThenPull
      : ManualSyncMode.pullOnly;
  await Navigator.of(context).push<void>(
    MaterialPageRoute<void>(
      builder: (_) => PostLoginCloudSyncScreen(
        totalRows: unsynced,
        localRows: localRows,
        remoteRows: null,
        isBootstrapOnly: mode == ManualSyncMode.pullOnly,
        runSync: (onStage) {
          final orchestrator = SyncOrchestrator(
            db: services.db,
            cloud: services.cloudSync,
            expenses: services.expenses,
            expenseLimits: services.expenseLimits,
            recurring: services.recurring,
          );
          return orchestrator.runManualSync(
            includeLocalOnly: localOnly > 0,
            includeError: mode == ManualSyncMode.pushThenPull,
            mode: mode,
            failFast: true,
            onStage: onStage,
          );
        },
      ),
    ),
  );
}

class _CategoryLeadingIcon extends StatelessWidget {
  const _CategoryLeadingIcon({required this.category});

  final ExpenseCategory? category;

  @override
  Widget build(BuildContext context) {
    final c = category;
    if (c != null) {
      return AppCard(
        padding: const EdgeInsets.all(AppSpacing.s8),
        borderRadius: AppRadius.xl,
        color: c.backgroundColor,
        child: Icon(c.icon, color: c.foregroundColor, size: AppSpacing.s20),
      );
    }
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.s8),
      borderRadius: AppRadius.xl,
      color: AppColors.surfaceContainerHighest,
      child: Icon(
        Icons.category_outlined,
        color: AppColors.onSurfaceVariant,
        size: AppSpacing.s20,
      ),
    );
  }
}
