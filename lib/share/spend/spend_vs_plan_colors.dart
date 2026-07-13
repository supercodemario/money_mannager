import 'package:flutter/material.dart';
import 'package:money_manager/share/tokens/app_colors.dart';

/// Semantic colors for daily (non-recurring) spend vs [Daily plan].
///
/// Use [resolve] so Home day grid, Expenses daily banner, and related UIs stay aligned.
class SpendVsPlanColors {
  const SpendVsPlanColors._();

  /// Daily spend above plan (past or today).
  static const Color over = AppColors.error;

  /// Daily spend at or under plan (past or today).
  static const Color underOrEqual = AppColors.secondary;

  /// No plan, unset limits, or a future calendar day.
  static const Color neutral = AppColors.onSurfaceVariant;

  /// Recurring portion of the day’s spend (not compared to plan).
  static const Color recurring = AppColors.tertiary;

  /// Plan label / amount.
  static const Color plan = AppColors.primary;

  /// Pace / day (remaining ÷ days after today).
  static const Color pace = AppColors.secondaryDim;

  /// Total spent that day (daily + recurring).
  static const Color totalSpent = AppColors.onSurface;

  /// Color for non-recurring daily spend relative to [planMinor].
  ///
  /// Future days and missing/non-positive plans use [neutral].
  static Color resolve({
    required int? planMinor,
    required int dailyMinor,
    required DateTime dayLocal,
    DateTime? nowLocal,
  }) {
    if (planMinor == null || planMinor <= 0) return neutral;

    final now = nowLocal ?? DateTime.now();
    final day = DateTime(dayLocal.year, dayLocal.month, dayLocal.day);
    final today = DateTime(now.year, now.month, now.day);
    if (day.isAfter(today)) return neutral;

    if (dailyMinor > planMinor) return over;
    return underOrEqual;
  }
}
