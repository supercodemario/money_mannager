import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTypography {
  const AppTypography._();

  static const displayFamily = 'Plus Jakarta Sans';
  static const bodyFamily = 'Manrope';

  static TextTheme textTheme(ColorScheme scheme) {
    // Use GoogleFonts to avoid bundling font assets initially.
    // We keep the mapping explicit so we can switch to bundled fonts later.
    final manrope = GoogleFonts.manropeTextTheme();

    // Start from a Manrope baseline for readability.
    final base = manrope.apply(
      bodyColor: scheme.onSurface,
      displayColor: scheme.onSurface,
    );

    // Override display/headline families to Plus Jakarta Sans.
    TextStyle? display(TextStyle? s) => (s ?? const TextStyle()).copyWith(
          fontFamily: displayFamily,
        );

    return base.copyWith(
      displayLarge: display(base.displayLarge),
      displayMedium: display(base.displayMedium),
      displaySmall: display(base.displaySmall),
      headlineLarge: display(base.headlineLarge),
      headlineMedium: display(base.headlineMedium),
      headlineSmall: display(base.headlineSmall),
      titleLarge: display(base.titleLarge),
      titleMedium: display(base.titleMedium),
      titleSmall: display(base.titleSmall),
      // Body/label remain Manrope via base.
    );
  }
}

