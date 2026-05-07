import 'package:drift/drift.dart';
import 'package:money_manager/data/categories/category_bucket.dart';
import 'package:money_manager/data/local/app_database.dart';

class CategoryRepository {
  CategoryRepository(this._db);

  final AppDatabase _db;

  Stream<List<ExpenseCategory>> watchAll() {
    return (_db.select(_db.expenseCategories)
          ..orderBy([(t) => OrderingTerm(expression: t.label, mode: OrderingMode.asc)]))
        .watch();
  }

  Future<List<ExpenseCategory>> listAll() {
    return (_db.select(_db.expenseCategories)
          ..orderBy([(t) => OrderingTerm(expression: t.label, mode: OrderingMode.asc)]))
        .get();
  }

  Future<ExpenseCategory?> getById(String id) {
    return (_db.select(_db.expenseCategories)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Future<void> updateBucket(String id, CategoryBucket bucket) {
    return (_db.update(_db.expenseCategories)..where((t) => t.id.equals(id))).write(
      ExpenseCategoriesCompanion(
        bucket: Value(bucket.dbValue),
        updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
      ),
    );
  }
}
