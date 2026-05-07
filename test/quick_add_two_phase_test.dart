import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:money_manager/app/app_services.dart';
import 'package:money_manager/app/cloud_sync_controller.dart';
import 'package:money_manager/data/local/app_database.dart';
import 'package:money_manager/features/add_expense/view/quick_add_screen.dart';
import 'package:money_manager/features/add_expense/widgets/quick_add_category_pager.dart';
import 'package:money_manager/features/add_expense/widgets/quick_add_keypad.dart';
import 'package:money_manager/share/share.dart';

void main() {
  testWidgets('Quick Add hides categories and hint until amount > 0 and mode switch', (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final cloud = CloudSyncController();
    await cloud.initialize();
    await tester.pumpWidget(
      AppServices(
        db: AppDatabase.memory(),
        cloudSync: cloud,
        child: MaterialApp(
          theme: AppTheme.light(),
          home: const QuickAddScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(QuickAddCategoryPager), findsNothing);
    expect(find.byType(QuickAddKeypad), findsOneWidget);
    expect(find.text(AppStrings.tapCategoryToSaveInstantly), findsNothing);

    final selectFinder = find.widgetWithText(FilledButton, AppStrings.selectCategoryTitle);
    expect(selectFinder, findsOneWidget);
    FilledButton selectBtn = tester.widget(selectFinder);
    expect(selectBtn.onPressed, isNull);

    await tester.tap(find.text('0'));
    await tester.pump();
    await tester.tap(find.text('.'));
    await tester.pump();
    await tester.tap(find.text('0'));
    await tester.pump();
    await tester.tap(find.text('1'));
    await tester.pumpAndSettle();

    selectBtn = tester.widget(selectFinder);
    expect(selectBtn.onPressed, isNotNull);

    await tester.tap(selectFinder);
    await tester.pumpAndSettle();

    expect(find.byType(QuickAddCategoryPager), findsOneWidget);
    expect(find.byType(QuickAddKeypad), findsOneWidget);
    expect(
      tester.widget<Visibility>(
        find.byWidgetPredicate((w) => w is Visibility && w.child is QuickAddKeypad),
      ).visible,
      isFalse,
    );
    expect(find.text(AppStrings.tapCategoryToSaveInstantly), findsOneWidget);

    await tester.tap(find.text(AppStrings.editAmount).first);
    await tester.pumpAndSettle();

    expect(find.byType(QuickAddCategoryPager), findsNothing);
    expect(find.byType(QuickAddKeypad), findsOneWidget);
    expect(find.text(AppStrings.tapCategoryToSaveInstantly), findsNothing);
  });
}
