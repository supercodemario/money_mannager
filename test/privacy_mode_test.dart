import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money_manager/data/local/privacy_mode_preferences.dart';
import 'package:money_manager/features/expenses/widgets/expenses_amount_format.dart';
import 'package:money_manager/share/regional/regional_formatting_data.dart';
import 'package:money_manager/share/regional/regional_formatting_scope.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PrivacyModePreferences', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('defaults to false', () async {
      expect(await PrivacyModePreferences.isEnabled(), isFalse);
    });

    test('persists enabled flag', () async {
      await PrivacyModePreferences.setEnabled(true);
      expect(await PrivacyModePreferences.isEnabled(), isTrue);
      await PrivacyModePreferences.setEnabled(false);
      expect(await PrivacyModePreferences.isEnabled(), isFalse);
    });
  });

  group('privacyAwareExpenseAmount', () {
    testWidgets('masks, reveals, and respects privacy off', (tester) async {
      late String masked;
      late String revealed;
      late String plain;
      late String expectedPlain;

      await tester.pumpWidget(
        RegionalFormattingScope(
          data: RegionalFormattingData.defaults,
          child: Builder(
            builder: (context) {
              masked = privacyAwareExpenseAmount(
                context,
                12_000,
                privacyEnabled: true,
                temporarilyRevealed: false,
              );
              revealed = privacyAwareExpenseAmount(
                context,
                12_000,
                privacyEnabled: true,
                temporarilyRevealed: true,
              );
              plain = privacyAwareExpenseAmount(
                context,
                12_000,
                privacyEnabled: false,
                temporarilyRevealed: false,
              );
              expectedPlain = formatExpenseMinor(context, 12_000);
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      expect(
        masked,
        '${RegionalFormattingData.defaults.currencySymbol} •••••',
      );
      expect(revealed, expectedPlain);
      expect(plain, expectedPlain);
    });
  });
}
