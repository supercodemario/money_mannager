import 'package:flutter/widgets.dart';
import 'package:money_manager/app/cloud_sync_controller.dart';
import 'package:money_manager/data/local/app_database.dart';
import 'package:money_manager/data/repositories/category_repository.dart';
import 'package:money_manager/data/repositories/expense_limits_repository.dart';
import 'package:money_manager/data/repositories/expense_repository.dart';
import 'package:money_manager/data/repositories/recurring_payment_repository.dart';
import 'package:money_manager/data/repositories/user_preferences_repository.dart';
import 'package:money_manager/data/repositories/user_profile_repository.dart';

class AppServices extends InheritedWidget {
  AppServices({
    super.key,
    required super.child,
    required this.db,
    required this.cloudSync,
  }) : profiles = UserProfileRepository(db) {
    expenses = ExpenseRepository(db, profiles, cloudSync);
    recurring = RecurringPaymentRepository(db, expenses);
    expenseLimits = ExpenseLimitsRepository(
      db,
      recurring,
      profiles: profiles,
      cloudSync: cloudSync,
    );
    categories = CategoryRepository(db);
    preferences = UserPreferencesRepository(db);
  }

  final AppDatabase db;
  final CloudSyncController cloudSync;
  final UserProfileRepository profiles;
  late final ExpenseRepository expenses;
  late final RecurringPaymentRepository recurring;
  late final ExpenseLimitsRepository expenseLimits;
  late final CategoryRepository categories;
  late final UserPreferencesRepository preferences;

  static AppServices of(BuildContext context) {
    final s = context.dependOnInheritedWidgetOfExactType<AppServices>();
    assert(s != null, 'AppServices not found in widget tree');
    return s!;
  }

  @override
  bool updateShouldNotify(covariant AppServices oldWidget) =>
      db != oldWidget.db || cloudSync != oldWidget.cloudSync;
}
