import 'package:flutter/material.dart';
import 'package:money_manager/share/share.dart';

/// First-run tutorial content for the Home tab (shown below [HomeRatioAppBar]).
class DashboardHomeTutorialBody extends StatelessWidget {
  const DashboardHomeTutorialBody({
    super.key,
    required this.onSetExpenseLimits,
    required this.onAddFirstExpense,
  });

  /// Opens expense limits (monthly guidance).
  final VoidCallback onSetExpenseLimits;

  /// Opens quick add for the first expense.
  final VoidCallback onAddFirstExpense;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return ColoredBox(
      color: AppColors.background,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16),
        children: [
          const SizedBox(height: AppSpacing.s8),
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.s12,
                vertical: AppSpacing.s6,
              ),
              decoration: BoxDecoration(
                color: AppColors.secondaryContainer,
                borderRadius: BorderRadius.circular(AppRadius.full),
              ),
              child: Text(
                AppStrings.getStartedBadge,
                style: textTheme.labelSmall?.copyWith(
                  color: AppColors.onSecondaryContainer,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.s24),
          Text(
            AppStrings.getStartedTitle,
            textAlign: TextAlign.center,
            style: textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: AppColors.onBackground,
              height: 1.15,
            ),
          ),
          const SizedBox(height: AppSpacing.s12),
          Text(
            AppStrings.getStartedSubtitle,
            textAlign: TextAlign.center,
            style: textTheme.bodyLarge?.copyWith(
              color: AppColors.onSurfaceVariant,
              height: 1.45,
            ),
          ),
          const SizedBox(height: AppSpacing.s32),
          _FeatureCard(
            icon: Icons.query_stats_rounded,
            iconBackground: AppColors.primaryContainer,
            iconColor: AppColors.primary,
            title: AppStrings.getStartedCardTrackTitle,
            body: AppStrings.getStartedCardTrackBody,
            child: const _FakeProgressTrack(),
          ),
          const SizedBox(height: AppSpacing.s16),
          _FeatureCard(
            icon: Icons.speed_rounded,
            iconBackground: AppColors.tertiaryContainer,
            iconColor: AppColors.onTertiaryContainer,
            title: AppStrings.getStartedCardLimitsTitle,
            body: AppStrings.getStartedCardLimitsBody,
            child: Wrap(
              spacing: AppSpacing.s8,
              runSpacing: AppSpacing.s8,
              children: [
                _ExampleChip(label: AppStrings.getStartedExampleDaily),
                _ExampleChip(label: AppStrings.getStartedExampleMonthly),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.s16),
          _FeatureCard(
            icon: Icons.add_card_rounded,
            iconBackground: AppColors.secondaryContainer,
            iconColor: AppColors.onSecondaryContainer,
            title: AppStrings.getStartedCardExpensesTitle,
            body: AppStrings.getStartedCardExpensesBody,
            largeIcon: true,
            child: const _SampleExpenseMock(),
          ),
          const SizedBox(height: AppSpacing.s16),
          _FeatureCard(
            icon: Icons.event_repeat_rounded,
            iconBackground: AppColors.primaryContainer,
            iconColor: AppColors.primary,
            title: AppStrings.getStartedCardRecurringTitle,
            body: AppStrings.getStartedCardRecurringBody,
            child: const _RecurringPaymentMock(),
          ),
          const SizedBox(height: AppSpacing.s32),
          SizedBox(
            width: double.infinity,
            child: AppPrimaryButton(
              onPressed: onAddFirstExpense,
              child: Text(AppStrings.getStartedPrimaryCta),
            ),
          ),
          TextButton(
            onPressed: onSetExpenseLimits,
            child: Text(
              AppStrings.getStartedSecondaryCta,
              style: textTheme.titleSmall?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.s24),
        ],
      ),
    );
  }
}

class _FakeProgressTrack extends StatelessWidget {
  const _FakeProgressTrack();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.full),
      child: SizedBox(
        height: AppSpacing.s8,
        child: Stack(
          fit: StackFit.expand,
          children: [
            ColoredBox(color: AppColors.surfaceContainerHighest),
            FractionallySizedBox(
              widthFactor: 0.66,
              alignment: Alignment.centerLeft,
              child: ColoredBox(color: AppColors.secondary),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExampleChip extends StatelessWidget {
  const _ExampleChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s12,
        vertical: AppSpacing.s6,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(AppRadius.r12),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppColors.outline,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}

class _SampleExpenseMock extends StatelessWidget {
  const _SampleExpenseMock();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return AspectRatio(
      aspectRatio: 1.35,
      child: Stack(
        fit: StackFit.expand,
        children: [
          AppCard(
            color: AppColors.surfaceContainerLowest,
            padding: const EdgeInsets.all(AppSpacing.s12),
            borderRadius: AppRadius.r12,
            child: Column(
              children: [
                _mockRow(AppColors.primaryContainer),
                const SizedBox(height: AppSpacing.s8),
                _mockRow(AppColors.secondaryContainer),
                const SizedBox(height: AppSpacing.s8),
                _mockRow(AppColors.tertiaryContainer),
              ],
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.only(bottom: AppSpacing.s8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    AppColors.surfaceContainerLow.withValues(alpha: 0.95),
                    AppColors.surfaceContainerLow.withValues(alpha: 0),
                  ],
                ),
              ),
              child: Text(
                AppStrings.getStartedSampleDataLabel,
                textAlign: TextAlign.center,
                style: textTheme.labelSmall?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _mockRow(Color dot) {
    return Row(
      children: [
        Container(
          width: AppSpacing.s32,
          height: AppSpacing.s32,
          decoration: BoxDecoration(
            color: dot,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: AppSpacing.s8),
        Expanded(
          child: Container(
            height: AppSpacing.s12,
            decoration: BoxDecoration(
              color: AppColors.surfaceContainer,
              borderRadius: BorderRadius.circular(AppRadius.full),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.s8),
        Container(
          width: AppSpacing.s32,
          height: AppSpacing.s12,
          decoration: BoxDecoration(
            color: AppColors.surfaceContainer,
            borderRadius: BorderRadius.circular(AppRadius.full),
          ),
        ),
      ],
    );
  }
}

class _RecurringPaymentMock extends StatelessWidget {
  const _RecurringPaymentMock();

  @override
  Widget build(BuildContext context) {
    return AppCard(
      color: AppColors.surfaceContainerLowest,
      borderRadius: AppRadius.r12,
      padding: const EdgeInsets.all(AppSpacing.s12),
      child: Column(
        children: [
          _row(AppColors.primary),
          const SizedBox(height: AppSpacing.s8),
          _row(AppColors.secondary),
          const SizedBox(height: AppSpacing.s8),
          _row(AppColors.tertiary),
        ],
      ),
    );
  }

  static Widget _row(Color accent) {
    return Row(
      children: [
        Container(
          width: AppSpacing.s32,
          height: AppSpacing.s32,
          decoration: BoxDecoration(
            color: accent.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.repeat_rounded, size: 18, color: accent),
        ),
        const SizedBox(width: AppSpacing.s8),
        Expanded(
          child: Container(
            height: AppSpacing.s12,
            decoration: BoxDecoration(
              color: AppColors.surfaceContainer,
              borderRadius: BorderRadius.circular(AppRadius.full),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.s8),
        Container(
          width: AppSpacing.s32 + AppSpacing.s8,
          height: AppSpacing.s12,
          decoration: BoxDecoration(
            color: AppColors.surfaceContainer,
            borderRadius: BorderRadius.circular(AppRadius.full),
          ),
        ),
      ],
    );
  }
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({
    required this.icon,
    required this.iconBackground,
    required this.iconColor,
    required this.title,
    required this.body,
    required this.child,
    this.largeIcon = false,
  });

  final IconData icon;
  final Color iconBackground;
  final Color iconColor;
  final String title;
  final String body;
  final Widget child;
  final bool largeIcon;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final iconSize = largeIcon ? 30.0 : 28.0;
    return AppCard(
      color: AppColors.surfaceContainerLowest,
      borderRadius: AppRadius.r12,
      padding: const EdgeInsets.all(AppSpacing.s24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: AppSpacing.s32 + AppSpacing.s16,
            height: AppSpacing.s32 + AppSpacing.s16,
            decoration: BoxDecoration(
              color: iconBackground,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: iconSize),
          ),
          const SizedBox(height: AppSpacing.s16),
          Text(
            title,
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: AppColors.onBackground,
            ),
          ),
          const SizedBox(height: AppSpacing.s8),
          Text(
            body,
            style: textTheme.bodySmall?.copyWith(
              color: AppColors.onSurfaceVariant,
              height: 1.5,
            ),
          ),
          const SizedBox(height: AppSpacing.s16),
          child,
        ],
      ),
    );
  }
}
