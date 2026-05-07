import 'package:flutter/material.dart';

class AppColors {
  const AppColors._();

  static const background = Color(0xFFF8F9FA);
  static const surface = Color(0xFFF8F9FA);
  static const surfaceBright = Color(0xFFF8F9FA);
  static const surfaceDim = Color(0xFFD5DBDD);
  static const surfaceTint = Color(0xFF01668B);

  static const surfaceContainerLowest = Color(0xFFFFFFFF);
  static const surfaceContainerLow = Color(0xFFF2F4F5);
  static const surfaceContainer = Color(0xFFEBEEF0);
  static const surfaceContainerHigh = Color(0xFFE5E9EB);
  static const surfaceContainerHighest = Color(0xFFDEE3E5);

  static const surfaceVariant = Color(0xFFDEE3E5);
  static const outline = Color(0xFF767C7E);
  static const outlineVariant = Color(0xFFAEB3B5);

  static const onBackground = Color(0xFF2E3335);
  static const onSurface = Color(0xFF2E3335);
  static const onSurfaceVariant = Color(0xFF5A6062);

  static const primary = Color(0xFF01668B);
  static const primaryDim = Color(0xFF00597A);
  static const primaryContainer = Color(0xFF8AD2FC);
  static const onPrimary = Color(0xFFF4F9FF);
  static const onPrimaryContainer = Color(0xFF004762);

  static const secondary = Color(0xFF116E20);
  static const secondaryDim = Color(0xFF006117);
  static const secondaryContainer = Color(0xFF9DF898);
  static const onSecondary = Color(0xFFEaffe2);
  static const onSecondaryContainer = Color(0xFF006016);

  static const tertiary = Color(0xFF974A00);
  static const tertiaryDim = Color(0xFF854000);
  static const tertiaryContainer = Color(0xFFFFA361);
  static const onTertiary = Color(0xFFFFF7F4);
  static const onTertiaryContainer = Color(0xFF5A2900);

  static const error = Color(0xFFAA371C);
  static const errorDim = Color(0xFF821A01);
  static const errorContainer = Color(0xFFFA7150);
  static const onError = Color(0xFFFFF7F6);
  static const onErrorContainer = Color(0xFF671200);

  static const inverseSurface = Color(0xFF0C0F10);
  static const inverseOnSurface = Color(0xFF9B9D9E);
  static const inversePrimary = Color(0xFF8AD2FC);

  /// Stitch Streamlined Expenses pill track (`bg-slate-200/50`).
  static Color get streamlinedExpensesTabTrackTint =>
      const Color(0xFFE2E8F0).withValues(alpha: 0.5);

  // Category tints (from Stitch UI references)
  static const categoryMedicalTint = Color(0xFFFFEBEE);
  static const categoryTravelTint = Color(0xFFFFF3E0);
  static const categoryCinemaTint = Color(0xFFE3F2FD);
  static const categoryHealthTint = Color(0xFFE8F5E9);

  /// Extra distinct tints so category chips do not repeat the same background in long lists.
  static const categoryOnlineTint = Color(0xFFF3E5F5);
  static const categoryOnlineOnTint = Color(0xFF6A1B9A);
  static const categoryVegetablesTint = Color(0xFFF1F8E9);
  static const categoryVegetablesOnTint = Color(0xFF33691E);
  static const categoryFuelTint = Color(0xFFFFF8E1);
  static const categoryVacationTint = Color(0xFFE8EAF6);
  static const categoryVacationOnTint = Color(0xFF3949AB);
  static const categorySavingsTint = Color(0xFFFFF9C4);
  static const categorySavingsOnTint = Color(0xFFF57F17);
}

