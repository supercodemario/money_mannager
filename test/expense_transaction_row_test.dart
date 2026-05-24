import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money_manager/app/cloud_sync_controller.dart';
import 'package:money_manager/data/local/app_database.dart';
import 'package:money_manager/data/repositories/expense_repository.dart';
import 'package:money_manager/data/repositories/user_profile_repository.dart';
import 'package:money_manager/features/add_expense/data/default_expense_categories.dart';
import 'package:money_manager/features/expenses/widgets/expense_transaction_row.dart';
import 'package:money_manager/share/share.dart';

void main() {
  testWidgets('ExpenseTransactionRow shows recorded-by line and keys avatar by user id', (
    WidgetTester tester,
  ) async {
    TestWidgetsFlutterBinding.ensureInitialized();

    final cloud = CloudSyncController();
    await cloud.initialize();

    final db = AppDatabase.memory();
    await db.ensureReady();
    final profiles = UserProfileRepository(db);
    final profile = await profiles.getCurrentProfile();
    final repo = ExpenseRepository(db, profiles, cloud);

    await repo.insertExpense(
      amountMinor: 100,
      currencyCode: 'USD',
      categoryId: 'grocery',
      occurredAt: DateTime.now(),
    );

    final expense =
        await (db.select(db.expenses)..limit(1)).getSingle();
    final category =
        defaultExpenseCategories().firstWhere((c) => c.id == 'grocery');

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: Scaffold(
          body: ExpenseTransactionRow(
            expense: expense,
            category: category,
            creatorUserId: profile.id,
            creatorDisplayName: profile.displayName,
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(
      find.text('${AppStrings.expenseRecordedBy} · ${profile.displayName}'),
      findsOneWidget,
    );
    expect(
      find.byKey(ValueKey<String>('member_avatar_${profile.id}')),
      findsOneWidget,
    );
  });
}
