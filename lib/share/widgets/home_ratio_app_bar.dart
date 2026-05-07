import 'package:flutter/material.dart';
import 'package:money_manager/share/tokens/tokens.dart';

/// App bar with HomeRatio branding (icon + title + notifications), shared by
/// the dashboard home screen and first-run Get Started (home tab).
class HomeRatioAppBar {
  HomeRatioAppBar._();

  static AppBar build(BuildContext context) {
    return AppBar(
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSpacing.s8),
            child: Image.asset(
              'assets/icons/homeratio_app_icon.png',
              width: 36,
              height: 36,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: AppSpacing.s8),
          const Text(AppStrings.dashboardTitle),
        ],
      ),
      actions: [
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.notifications_outlined),
        ),
      ],
    );
  }
}
