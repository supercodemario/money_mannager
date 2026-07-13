import 'package:flutter_test/flutter_test.dart';
import 'package:money_manager/share/spend/spend_vs_plan_colors.dart';
import 'package:money_manager/share/tokens/app_colors.dart';

void main() {
  group('SpendVsPlanColors.resolve', () {
    final today = DateTime(2026, 7, 13);

    test('over plan is error color', () {
      expect(
        SpendVsPlanColors.resolve(
          planMinor: 100,
          dailyMinor: 150,
          dayLocal: today,
          nowLocal: today,
        ),
        AppColors.error,
      );
      expect(SpendVsPlanColors.over, AppColors.error);
    });

    test('under or equal plan is secondary', () {
      expect(
        SpendVsPlanColors.resolve(
          planMinor: 100,
          dailyMinor: 100,
          dayLocal: today,
          nowLocal: today,
        ),
        AppColors.secondary,
      );
      expect(
        SpendVsPlanColors.resolve(
          planMinor: 100,
          dailyMinor: 40,
          dayLocal: today,
          nowLocal: today,
        ),
        AppColors.secondary,
      );
      expect(SpendVsPlanColors.underOrEqual, AppColors.secondary);
    });

    test('future day and missing plan are neutral', () {
      expect(
        SpendVsPlanColors.resolve(
          planMinor: 100,
          dailyMinor: 0,
          dayLocal: DateTime(2026, 7, 20),
          nowLocal: today,
        ),
        AppColors.onSurfaceVariant,
      );
      expect(
        SpendVsPlanColors.resolve(
          planMinor: null,
          dailyMinor: 50,
          dayLocal: today,
          nowLocal: today,
        ),
        AppColors.onSurfaceVariant,
      );
      expect(SpendVsPlanColors.neutral, AppColors.onSurfaceVariant);
    });
  });
}
