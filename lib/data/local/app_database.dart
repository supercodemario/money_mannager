import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3_flutter_libs/sqlite3_flutter_libs.dart';
import 'package:uuid/uuid.dart';

import 'package:money_manager/share/tokens/app_strings.dart';

part 'app_database.g.dart';

class UserProfiles extends Table {
  TextColumn get id => text()();
  TextColumn get displayName => text()();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();
  TextColumn get remoteId => text().nullable()();
  TextColumn get syncStatus => text().nullable()();
  IntColumn get serverUpdatedAt => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class RecurringPayments extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get categoryId => text()();
  IntColumn get amountMinorSuggested => integer()();
  TextColumn get currencyCode => text()();
  IntColumn get dayOfMonth => integer()();

  /// Optional inclusive end month for this recurring template (`YYYY-MM` in local calendar).
  /// When null, the template recurs indefinitely.
  TextColumn get endMonthKey => text().nullable()();

  /// When false, the template is hidden from Expenses → Recurring and home; management screen still lists it.
  BoolColumn get isEnabled => boolean().withDefault(const Constant(true))();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();
  TextColumn get remoteId => text().nullable()();
  TextColumn get syncStatus => text().nullable()();
  IntColumn get serverUpdatedAt => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@TableIndex(name: 'expenses_occurred_at', columns: {#occurredAt})
@TableIndex(
  name: 'expenses_category_occurred',
  columns: {#categoryId, #occurredAt},
)
@TableIndex(name: 'expenses_created_by', columns: {#createdByUserId})
class Expenses extends Table {
  TextColumn get id => text()();
  IntColumn get amountMinor => integer()();
  TextColumn get currencyCode => text()();
  TextColumn get categoryId => text()();
  TextColumn get budgetBucket => text().nullable()();
  TextColumn get note => text().nullable()();
  IntColumn get occurredAt => integer()();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();
  TextColumn get createdByUserId => text().references(UserProfiles, #id)();
  TextColumn get recurringPaymentId =>
      text().nullable().references(RecurringPayments, #id)();
  TextColumn get remoteId => text().nullable()();
  TextColumn get syncStatus => text().nullable()();
  IntColumn get serverUpdatedAt => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Per-user expense limit inputs for indicative daily/monthly guidance (v1: single local profile).
class ExpenseLimitPreferences extends Table {
  TextColumn get userId => text().references(UserProfiles, #id)();
  IntColumn get monthlyIncomeMinor => integer().nullable()();
  IntColumn get monthlySavingsMinor => integer().nullable()();
  BoolColumn get excludeUnpaidRecurring =>
      boolean().withDefault(const Constant(false))();
  IntColumn get updatedAt => integer()();
  TextColumn get remoteId => text().nullable()();
  TextColumn get syncStatus => text().nullable()();
  IntColumn get serverUpdatedAt => integer().nullable()();

  @override
  Set<Column> get primaryKey => {userId};
}

class UserPreferences extends Table {
  TextColumn get userId => text().references(UserProfiles, #id)();
  TextColumn get currencyCode => text().withDefault(const Constant('USD'))();
  TextColumn get languageCode => text().withDefault(const Constant('en'))();
  TextColumn get numberFormat => text().withDefault(const Constant('us'))();
  IntColumn get updatedAt => integer()();

  @override
  Set<Column> get primaryKey => {userId};
}

class ExpenseCategories extends Table {
  TextColumn get id => text()();
  TextColumn get label => text()();
  TextColumn get bucket => text()();
  BoolColumn get isBuiltIn => boolean().withDefault(const Constant(false))();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

@TableIndex(
  name: 'idx_rp_occurrence_unique',
  columns: {#recurringPaymentId, #monthKey},
  unique: true,
)
class RecurringPaymentOccurrences extends Table {
  TextColumn get id => text()();
  TextColumn get recurringPaymentId =>
      text().references(RecurringPayments, #id)();
  TextColumn get monthKey => text()();
  TextColumn get expenseId => text().nullable().references(Expenses, #id)();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer().withDefault(const Constant(0))();
  TextColumn get remoteId => text().nullable()();
  TextColumn get syncStatus => text().nullable()();
  IntColumn get serverUpdatedAt => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(
  tables: [
    UserProfiles,
    RecurringPayments,
    Expenses,
    RecurringPaymentOccurrences,
    ExpenseLimitPreferences,
    UserPreferences,
    ExpenseCategories,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  /// In-memory database for tests.
  AppDatabase.memory() : super(NativeDatabase.memory());

  @override
  int get schemaVersion => 8;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
    },
    onUpgrade: (Migrator m, int from, int to) async {
      if (from < 2) {
        await m.createTable(recurringPayments);
        await m.addColumn(expenses, expenses.recurringPaymentId);
        await m.createTable(recurringPaymentOccurrences);
      }
      if (from < 3) {
        await m.addColumn(recurringPayments, recurringPayments.endMonthKey);
      }
      if (from < 4) {
        await m.addColumn(recurringPayments, recurringPayments.isEnabled);
      }
      if (from < 5) {
        await m.createTable(expenseLimitPreferences);
      }
      if (from < 6) {
        await m.addColumn(expenses, expenses.budgetBucket);
        await m.createTable(userPreferences);
        await m.createTable(expenseCategories);
      }
      if (from < 7) {
        await m.addColumn(
          expenseLimitPreferences,
          expenseLimitPreferences.remoteId,
        );
        await m.addColumn(
          expenseLimitPreferences,
          expenseLimitPreferences.syncStatus,
        );
        await m.addColumn(
          expenseLimitPreferences,
          expenseLimitPreferences.serverUpdatedAt,
        );
      }
      if (from < 8) {
        await m.addColumn(recurringPayments, recurringPayments.isDeleted);
        await m.addColumn(recurringPayments, recurringPayments.remoteId);
        await m.addColumn(recurringPayments, recurringPayments.syncStatus);
        await m.addColumn(recurringPayments, recurringPayments.serverUpdatedAt);
        await m.addColumn(
          recurringPaymentOccurrences,
          recurringPaymentOccurrences.isDeleted,
        );
        await m.addColumn(
          recurringPaymentOccurrences,
          recurringPaymentOccurrences.updatedAt,
        );
        await customStatement(
          'UPDATE recurring_payment_occurrences SET updated_at = created_at WHERE updated_at = 0',
        );
        await m.addColumn(
          recurringPaymentOccurrences,
          recurringPaymentOccurrences.remoteId,
        );
        await m.addColumn(
          recurringPaymentOccurrences,
          recurringPaymentOccurrences.syncStatus,
        );
        await m.addColumn(
          recurringPaymentOccurrences,
          recurringPaymentOccurrences.serverUpdatedAt,
        );
      }
    },
    beforeOpen: (OpeningDetails details) async {
      await customStatement('PRAGMA foreign_keys = ON');
      await _ensureDefaultProfile();
      await _syncExpenseCategoryCatalog();
    },
  );

  Future<void> ensureReady() async {
    await customSelect('SELECT 1').getSingle();
  }

  Future<void> wipeLocalData() async {
    await transaction(() async {
      await delete(recurringPaymentOccurrences).go();
      await delete(expenses).go();
      await delete(recurringPayments).go();
      await delete(expenseLimitPreferences).go();
      await delete(userPreferences).go();
      await delete(userProfiles).go();
    });
    await _ensureDefaultProfile();
    await _syncExpenseCategoryCatalog();
  }

  Future<void> _ensureDefaultProfile() async {
    final existing = await select(userProfiles).get();
    if (existing.isNotEmpty) return;
    final now = DateTime.now().millisecondsSinceEpoch;
    await into(userProfiles).insert(
      UserProfilesCompanion.insert(
        id: const Uuid().v4(),
        displayName: AppStrings.defaultUserDisplayName,
        createdAt: now,
        updatedAt: now,
      ),
    );
  }

  /// Inserts missing built-in categories and refreshes display labels (does not overwrite user bucket edits).
  Future<void> _syncExpenseCategoryCatalog() async {
    final now = DateTime.now().millisecondsSinceEpoch;
    const catalog = <(String id, String label, String bucket)>[
      ('house', AppStrings.categoryHousing, 'needs'),
      ('medical', AppStrings.categoryMedical, 'needs'),
      ('travel', AppStrings.categoryTravel, 'wants'),
      ('grocery', AppStrings.categoryGrocery, 'needs'),
      ('bill', AppStrings.categoryUtilitiesBills, 'needs'),
      ('out-eat', AppStrings.categoryDiningOut, 'wants'),
      ('cinema', AppStrings.categoryCinema, 'wants'),
      ('health', AppStrings.categoryHealth, 'needs'),
      ('online-shopping', AppStrings.categoryOnlineShopping, 'wants'),
      ('vegetables', AppStrings.categoryVegetables, 'needs'),
      ('fuel', AppStrings.categoryFuel, 'needs'),
      ('vacation', AppStrings.categoryVacation, 'wants'),
      ('savings', AppStrings.categorySavings, 'savings_debt'),
    ];

    for (final (id, label, bucket) in catalog) {
      final row = await (select(
        expenseCategories,
      )..where((t) => t.id.equals(id))).getSingleOrNull();
      if (row == null) {
        await into(expenseCategories).insert(
          ExpenseCategoriesCompanion.insert(
            id: id,
            label: label,
            bucket: bucket,
            isBuiltIn: const Value(true),
            createdAt: now,
            updatedAt: now,
          ),
        );
      } else {
        await (update(expenseCategories)..where((t) => t.id.equals(id))).write(
          ExpenseCategoriesCompanion(
            label: Value(label),
            updatedAt: Value(now),
          ),
        );
      }
    }
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    if (Platform.isAndroid) {
      await applyWorkaroundToOpenSqlite3OnOldAndroidVersions();
    }
    final dir = await getApplicationSupportDirectory();
    final file = File(p.join(dir.path, 'money_manager.db'));
    return NativeDatabase.createInBackground(file);
  });
}
