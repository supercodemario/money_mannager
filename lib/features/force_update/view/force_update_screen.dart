import 'package:flutter/material.dart';
import 'package:money_manager/features/force_update/models/force_update_policy/force_update_policy.dart';
import 'package:money_manager/share/share.dart';
import 'package:url_launcher/url_launcher.dart';

/// Non-dismissible Android force-update screen.
class ForceUpdateScreen extends StatelessWidget {
  const ForceUpdateScreen({
    super.key,
    required this.policy,
  });

  final ForceUpdatePolicy policy;

  Future<void> _openStore() async {
    final uri = Uri.tryParse(policy.storeUrl);
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final body = (policy.message != null && policy.message!.trim().isNotEmpty)
        ? policy.message!.trim()
        : AppStrings.forceUpdateBody;

    return PopScope(
      canPop: false,
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.s24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Spacer(),
                Icon(
                  Icons.system_update_alt_rounded,
                  size: AppSpacing.s48,
                  color: AppColors.primary,
                ),
                const SizedBox(height: AppSpacing.s24),
                Text(
                  AppStrings.forceUpdateTitle,
                  textAlign: TextAlign.center,
                  style: textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: AppSpacing.s12),
                Text(
                  body,
                  textAlign: TextAlign.center,
                  style: textTheme.bodyMedium?.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                const Spacer(),
                AppPrimaryButton(
                  onPressed: _openStore,
                  child: const Text(AppStrings.forceUpdateCta),
                ),
                const SizedBox(height: AppSpacing.s16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
