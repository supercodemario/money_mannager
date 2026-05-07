// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can use WidgetTester to find child widgets in the widget tree,
// read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:money_manager/app/cloud_sync_controller.dart';
import 'package:money_manager/data/local/app_database.dart';
import 'package:money_manager/main.dart';
import 'package:money_manager/share/share.dart';

void main() {
  testWidgets('App boots with bottom navigation shell', (WidgetTester tester) async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues(<String, Object>{'get_started_completed': true});

    final cloud = CloudSyncController();
    await cloud.initialize();
    await tester.pumpWidget(
      MyApp(
        db: AppDatabase.memory(),
        cloudSync: cloud,
        enableSyncLifecycle: false,
      ),
    );
    // Avoid pumpAndSettle: home may show an indeterminate [CircularProgressIndicator] during bootstrap.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text(AppStrings.dashboardTitle), findsOneWidget);
    expect(find.text(AppStrings.totalFamilyBudgetLabel), findsOneWidget);
    expect(find.text(AppStrings.upcomingBills), findsOneWidget);

    expect(find.text(AppStrings.navHome), findsOneWidget);
    expect(find.text(AppStrings.navExpenses), findsOneWidget);
    expect(find.text(AppStrings.navAdd), findsOneWidget);
    expect(find.text(AppStrings.navInsights), findsOneWidget);
    expect(find.text(AppStrings.navSettings), findsOneWidget);

    // Drift stream queries schedule timers on dispose; flush them before teardown.
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 500));
  });
}
