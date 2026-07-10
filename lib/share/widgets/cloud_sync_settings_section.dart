import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:money_manager/app/app_router.dart';
import 'package:money_manager/app/app_services.dart';
import 'package:money_manager/share/share.dart';

/// Cloud sync summary; opens [AuthRoute] for login / manage account.
class CloudSyncSettingsSection extends StatelessWidget {
  const CloudSyncSettingsSection({super.key});

  Future<void> _openAuth(BuildContext context) async {
    await context.router.push<void>(const AuthRoute());
  }

  @override
  Widget build(BuildContext context) {
    final cloud = AppServices.of(context).cloudSync;
    final textTheme = Theme.of(context).textTheme;

    return KeyedSubtree(
      key: const ValueKey<String>('cloud_sync_settings_section'),
      child: ListenableBuilder(
        listenable: cloud,
        builder: (context, _) {
          if (!cloud.isSupabaseConfigured) {
            return AppCard(
              padding: const EdgeInsets.all(AppSpacing.s16),
              borderRadius: AppRadius.xl,
              child: Text(
                AppStrings.cloudSyncNotConfigured,
                style: textTheme.bodySmall?.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            );
          }

          final signedIn = cloud.session != null;

          return AppCard(
            padding: const EdgeInsets.all(AppSpacing.s16),
            borderRadius: AppRadius.xl,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  AppStrings.cloudSyncSectionTitle,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: AppSpacing.s8),
                if (signedIn) ...[
                  Text(
                    '${AppStrings.cloudSyncSignedIn}: ${cloud.session!.user.email ?? '—'}',
                    style: textTheme.bodyMedium,
                  ),
                  if (cloud.syncAllowed)
                    Padding(
                      padding: const EdgeInsets.only(top: AppSpacing.s4),
                      child: Text(
                        AppStrings.cloudSyncSyncReady,
                        style: textTheme.labelSmall?.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  const SizedBox(height: AppSpacing.s12),
                  FilledButton(
                    onPressed: () => _openAuth(context),
                    child: Text(AppStrings.cloudSyncManageAccountButton),
                  ),
                ] else ...[
                  Text(
                    AppStrings.authScreenSubtitle,
                    style: textTheme.bodySmall?.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s12),
                  FilledButton(
                    onPressed: () => _openAuth(context),
                    child: Text(AppStrings.cloudSyncOpenAuthButton),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
