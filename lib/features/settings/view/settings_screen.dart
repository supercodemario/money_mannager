import 'package:flutter/material.dart';
import 'package:money_manager/app/app_services.dart';
import 'package:money_manager/app/profile_details_scope.dart';
import 'package:money_manager/features/family_list/view/family_list_screen.dart';
import 'package:money_manager/features/settings/view/expense_limits_screen.dart';
import 'package:money_manager/features/settings/view/preferences_details_screen.dart';
import 'package:money_manager/features/settings/view/recurring_templates_management_screen.dart';
import 'package:money_manager/share/share.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _biometricEnabled = true;
  bool _pushEnabled = true;

  @override
  Widget build(BuildContext context) {
    final services = AppServices.of(context);
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.navSettings)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.s16),
        child: FutureBuilder(
          future: services.profiles.getCurrentProfile(),
          builder: (context, snapshot) {
            final profile = snapshot.data;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  AppStrings.settingsSubtitle,
                  style: textTheme.bodySmall?.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppSpacing.s16),
                Text(
                  AppStrings.profileTitle,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: AppSpacing.s12),
                AppCard(
                  padding: const EdgeInsets.all(AppSpacing.s16),
                  borderRadius: AppRadius.xl,
                  child: Semantics(
                    label: AppStrings.profileDetailsOpenSemanticsLabel,
                    button: true,
                    child: InkWell(
                      onTap: profile == null
                          ? null
                          : () {
                              ProfileDetailsScope.of(
                                context,
                              ).pushProfileDetails(context);
                            },
                      borderRadius: BorderRadius.circular(AppRadius.r12),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.s4,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    AppStrings.displayNameLabel,
                                    style: textTheme.labelSmall?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.onSurfaceVariant,
                                    ),
                                  ),
                                  const SizedBox(height: AppSpacing.s4),
                                  Text(
                                    profile?.displayName ?? '…',
                                    style: textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.chevron_right_rounded,
                              color: AppColors.onSurfaceVariant,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.s16),
                ListenableBuilder(
                  listenable: services.cloudSync,
                  builder: (context, _) {
                    final showFamily = services.cloudSync.syncAllowed;
                    return GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: AppSpacing.s12,
                      crossAxisSpacing: AppSpacing.s12,
                      childAspectRatio: 1.05,
                      children: [
                        StreamBuilder<int>(
                          stream: services.recurring
                              .watchEnabledTemplateCount(),
                          builder: (context, countSnap) {
                            final active = countSnap.data ?? 0;
                            return _SettingsGridCard(
                              icon: Icons.autorenew_rounded,
                              iconBackground: AppColors.secondaryContainer
                                  .withValues(alpha: 0.5),
                              iconColor: AppColors.secondaryDim,
                              title: AppStrings.settingsCardRecurring,
                              subtitle: AppStrings.settingsCardRecurringAmount,
                              badge:
                                  AppStrings.settingsCardRecurringActiveBadge(
                                    active,
                                  ),
                              badgeStyle: _BadgeStyle.emerald,
                              onTap: () {
                                Navigator.of(context).push<void>(
                                  MaterialPageRoute<void>(
                                    builder: (context) =>
                                        const RecurringTemplatesManagementScreen(),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                        if (showFamily)
                          _SettingsGridCard(
                            icon: Icons.group_rounded,
                            iconBackground: AppColors.primaryContainer
                                .withValues(alpha: 0.35),
                            iconColor: AppColors.primary,
                            title: AppStrings.settingsCardFamily,
                            subtitle: AppStrings.settingsCardFamilySubtitle,
                            trailingAvatars: true,
                            onTap: () {
                              Navigator.of(context).push<void>(
                                MaterialPageRoute<void>(
                                  builder: (context) =>
                                      const FamilyListScreen(),
                                ),
                              );
                            },
                          ),
                        _SettingsGridCard(
                          icon: Icons.speed_rounded,
                          iconBackground: AppColors.tertiaryContainer
                              .withValues(alpha: 0.35),
                          iconColor: AppColors.tertiary,
                          title: AppStrings.settingsCardLimits,
                          badge: AppStrings.settingsCardLimitsBadge,
                          badgeStyle: _BadgeStyle.teal,
                          progress: 0.45,
                          onTap: () {
                            Navigator.of(context).push<void>(
                              MaterialPageRoute<void>(
                                builder: (context) =>
                                    const ExpenseLimitsScreen(),
                              ),
                            );
                          },
                        ),
                        _SettingsGridCard(
                          icon: Icons.tune_rounded,
                          iconBackground: AppColors.surfaceVariant.withValues(
                            alpha: 0.5,
                          ),
                          iconColor: AppColors.onSurfaceVariant,
                          title: AppStrings.settingsCardPreferences,
                          subtitle: AppStrings.settingsCardPreferencesSubtitle,
                          badge: AppStrings.settingsCardPreferencesBadge,
                          badgeStyle: _BadgeStyle.neutral,
                          onTap: () {
                            Navigator.of(context).push<void>(
                              MaterialPageRoute<void>(
                                builder: (context) =>
                                    const PreferencesDetailsScreen(),
                              ),
                            );
                          },
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: AppSpacing.s12),
                _BiometricToggleCard(
                  enabled: _biometricEnabled,
                  onChanged: (v) => setState(() => _biometricEnabled = v),
                ),
                const SizedBox(height: AppSpacing.s12),
                _PushToggleRow(
                  enabled: _pushEnabled,
                  onChanged: (v) => setState(() => _pushEnabled = v),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

enum _BadgeStyle { emerald, teal, neutral }

class _SettingsGridCard extends StatelessWidget {
  const _SettingsGridCard({
    required this.icon,
    required this.iconBackground,
    required this.iconColor,
    required this.title,
    required this.onTap,
    this.subtitle,
    this.badge,
    this.badgeStyle = _BadgeStyle.neutral,
    this.progress,
    this.trailingAvatars = false,
  });

  final IconData icon;
  final Color iconBackground;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final String? badge;
  final _BadgeStyle badgeStyle;
  final double? progress;
  final bool trailingAvatars;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    Color? badgeBg;
    Color? badgeFg;
    switch (badgeStyle) {
      case _BadgeStyle.emerald:
        badgeBg = AppColors.secondaryContainer.withValues(alpha: 0.85);
        badgeFg = AppColors.secondaryDim;
        break;
      case _BadgeStyle.teal:
        badgeBg = AppColors.surfaceContainerLow.withValues(alpha: 0);
        badgeFg = AppColors.secondaryDim;
        break;
      case _BadgeStyle.neutral:
        badgeBg = AppColors.surfaceContainerLow.withValues(alpha: 0);
        badgeFg = AppColors.onSurfaceVariant;
        break;
    }

    return Material(
      color: AppColors.surfaceContainerLow,
      borderRadius: BorderRadius.circular(AppRadius.xl),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.s16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: iconBackground,
                      borderRadius: BorderRadius.circular(AppRadius.r12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.s8),
                      child: Icon(icon, size: AppSpacing.s24, color: iconColor),
                    ),
                  ),
                  const Spacer(),
                  if (trailingAvatars)
                    Row(
                      children: [
                        _avatar(context),
                        Transform.translate(
                          offset: const Offset(-AppSpacing.s8, 0),
                          child: _avatar(context),
                        ),
                      ],
                    )
                  else if (badge != null && badgeStyle != _BadgeStyle.teal)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.s8,
                        vertical: AppSpacing.s4,
                      ),
                      decoration: BoxDecoration(
                        color: badgeBg,
                        borderRadius: BorderRadius.circular(AppSpacing.s32),
                      ),
                      child: Text(
                        badge!,
                        style: textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: badgeFg,
                          fontSize: 10,
                        ),
                      ),
                    )
                  else if (badge != null)
                    Text(
                      badge!,
                      style: textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: badgeFg,
                      ),
                    ),
                ],
              ),
              const Spacer(),
              Text(
                title,
                style: textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: AppSpacing.s4),
                Text(
                  subtitle!,
                  style: textTheme.labelSmall?.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
              if (progress != null) ...[
                const SizedBox(height: AppSpacing.s8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppSpacing.s4),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: AppSpacing.s4,
                    backgroundColor: AppColors.surfaceContainerHighest,
                    color: AppColors.secondary,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _avatar(BuildContext context) {
    return Container(
      width: AppSpacing.s24,
      height: AppSpacing.s24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.surfaceContainerLowest, width: 2),
        color: AppColors.surfaceContainer,
      ),
      child: Icon(
        Icons.person_rounded,
        size: AppSpacing.s14,
        color: AppColors.onSurfaceVariant,
      ),
    );
  }
}

class _BiometricToggleCard extends StatelessWidget {
  const _BiometricToggleCard({required this.enabled, required this.onChanged});

  final bool enabled;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.xl),
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [AppColors.secondaryDim, AppColors.secondary],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondary.withValues(alpha: 0.25),
            blurRadius: AppSpacing.s12,
            offset: const Offset(0, AppSpacing.s4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.s16),
        child: Row(
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.onPrimary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(AppRadius.r12),
              ),
              child: const Padding(
                padding: EdgeInsets.all(AppSpacing.s8),
                child: Icon(
                  Icons.verified_user_rounded,
                  size: AppSpacing.s20,
                  color: AppColors.onPrimary,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.s12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.settingsBiometricTitle,
                    style: textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.onPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s4),
                  Text(
                    AppStrings.settingsBiometricSubtitle,
                    style: textTheme.labelSmall?.copyWith(
                      color: AppColors.onSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              value: enabled,
              onChanged: onChanged,
              activeThumbColor: AppColors.surfaceContainerLowest,
              activeTrackColor: AppColors.secondaryContainer,
              inactiveThumbColor: AppColors.onPrimary,
              inactiveTrackColor: AppColors.onPrimary.withValues(alpha: 0.3),
            ),
          ],
        ),
      ),
    );
  }
}

class _PushToggleRow extends StatelessWidget {
  const _PushToggleRow({required this.enabled, required this.onChanged});

  final bool enabled;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.s16),
      borderRadius: AppRadius.xl,
      color: AppColors.surfaceContainerLow,
      child: Row(
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(AppRadius.r12),
              boxShadow: [
                BoxShadow(
                  color: AppColors.onSurface.withValues(alpha: 0.06),
                  blurRadius: AppSpacing.s4,
                  offset: const Offset(0, AppSpacing.s2),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.s8),
              child: Icon(
                Icons.notifications_outlined,
                size: AppSpacing.s24,
                color: AppColors.secondaryDim,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.s12),
          Expanded(
            child: Text(
              AppStrings.settingsPushNotifications,
              style: textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Switch(
            value: enabled,
            onChanged: onChanged,
            activeThumbColor: AppColors.secondary,
            activeTrackColor: AppColors.secondaryContainer,
          ),
        ],
      ),
    );
  }
}
