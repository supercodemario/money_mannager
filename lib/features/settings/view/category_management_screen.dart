import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:money_manager/app/app_services.dart';
import 'package:money_manager/data/categories/category_bucket.dart';
import 'package:money_manager/features/add_expense/data/category_visuals.dart';
import 'package:money_manager/share/share.dart';

@RoutePage()
class CategoryManagementScreen extends StatelessWidget {
  const CategoryManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final services = AppServices.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.categoryManagementTitle)),
      body: SafeArea(
        child: StreamBuilder(
          stream: services.categories.watchAll(),
          builder: (context, snap) {
            final rows = snap.data ?? [];
            return ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.s16),
              itemCount: rows.length,
              separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.s8),
              itemBuilder: (context, index) {
                final row = rows[index];
                final bucket = categoryBucketFromDb(row.bucket);
                final visualCategory = mapDbCategoryToExpenseCategory(row);
                return AppCard(
                  padding: const EdgeInsets.all(AppSpacing.s12),
                  child: Row(
                    children: [
                      AppCard(
                        padding: const EdgeInsets.all(AppSpacing.s8),
                        borderRadius: AppRadius.xl,
                        color: visualCategory.backgroundColor,
                        child: Icon(
                          visualCategory.icon,
                          color: visualCategory.foregroundColor,
                          size: AppSpacing.s20,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.s12),
                      Expanded(
                        child: Text(
                          row.label,
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ),
                      DropdownButton<CategoryBucket>(
                        value: bucket,
                        items: [
                          for (final b in CategoryBucket.values)
                            DropdownMenuItem<CategoryBucket>(
                              value: b,
                              child: Text(b.displayLabel),
                            ),
                        ],
                        onChanged: (v) async {
                          if (v == null) return;
                          await services.categories.updateBucket(row.id, v);
                        },
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
