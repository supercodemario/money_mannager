import 'package:money_manager/data/local/app_database.dart';
import 'package:money_manager/data/remote/sync_constants.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Remote expense rows — only called from [SyncOrchestrator].
///
/// Pull queries rely on RLS (`expenses_select_member`: `household_id in
/// user_household_ids()`). Push includes each row's stored [Expense.householdId].
class ExpenseRemoteGateway {
  ExpenseRemoteGateway();

  /// Count visible to the signed-in user across all member households (RLS-scoped).
  Future<int> countExpenses() async {
    final c = Supabase.instance.client;
    final rows = await c.from('expenses').select('id') as List<dynamic>;
    return rows.length;
  }

  Future<void> upsertExpense({required Expense row}) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      throw StateError('Cannot upsert expense without auth session');
    }
    final householdId = row.householdId;
    if (householdId == null || householdId.isEmpty) {
      throw StateError('Cannot upsert expense without household_id on row ${row.id}');
    }

    await Supabase.instance.client.from('expenses').upsert(<String, dynamic>{
      'id': row.id,
      'household_id': householdId,
      'auth_user_id': user.id,
      'amount_minor': row.amountMinor,
      'currency_code': row.currencyCode,
      'category_id': row.categoryId,
      'budget_bucket': row.budgetBucket,
      'note': row.note,
      'occurred_at': row.occurredAt,
      'created_at': row.createdAt,
      'updated_at': row.updatedAt,
      'recurring_payment_id': row.recurringPaymentId,
      'remote_id': row.remoteId ?? row.id,
      'sync_status': SyncStatusValue.synced,
      'server_updated_at': DateTime.now().millisecondsSinceEpoch,
    });
  }

  /// Returns remote rows with [updated_at] strictly greater than [sinceUpdatedAtMs] when [sinceUpdatedAtMs] &gt; 0.
  ///
  /// No `household_id` filter — membership RLS scopes results to all households the user belongs to.
  Future<List<Map<String, dynamic>>> fetchExpensesSince({
    required int sinceUpdatedAtMs,
  }) async {
    final c = Supabase.instance.client;
    final List<dynamic> raw;
    if (sinceUpdatedAtMs <= 0) {
      raw =
          await c.from('expenses').select().order('updated_at', ascending: true)
              as List<dynamic>;
    } else {
      raw =
          await c
                  .from('expenses')
                  .select()
                  .gt('updated_at', sinceUpdatedAtMs)
                  .order('updated_at', ascending: true)
              as List<dynamic>;
    }
    return raw
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList(growable: false);
  }
}
