import 'package:flutter/material.dart';
import 'package:money_manager/app/app_services.dart';
import 'package:money_manager/features/auth/view/auth_screen.dart';
import 'package:money_manager/share/share.dart';

/// Settings summary for cloud sync; opens [AuthScreen] for login/sign-up.
class CloudSyncSettingsSection extends StatelessWidget {
  const CloudSyncSettingsSection({super.key});

  Future<void> _openAuth(BuildContext context) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (context) => const AuthScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cloud = AppServices.of(context).cloudSync;
    final textTheme = Theme.of(context).textTheme;

    return ListenableBuilder(
      listenable: cloud,
      builder: (context, _) {
        if (!cloud.isSupabaseConfigured) {
          return AppCard(
            padding: const EdgeInsets.all(AppSpacing.s16),
            borderRadius: AppRadius.xl,
            child: Text(
              AppStrings.cloudSyncNotConfigured,
              style: textTheme.bodySmall?.copyWith(color: AppColors.onSurfaceVariant),
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
                style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
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
                      style: textTheme.labelSmall?.copyWith(color: AppColors.primary),
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
                  style: textTheme.bodySmall?.copyWith(color: AppColors.onSurfaceVariant),
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
    );
  }
}
