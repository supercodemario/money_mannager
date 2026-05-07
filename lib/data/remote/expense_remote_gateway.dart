import 'package:money_manager/data/local/app_database.dart';
import 'package:money_manager/data/remote/sync_constants.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Remote expense rows — only called from [SyncOrchestrator].
class ExpenseRemoteGateway {
  ExpenseRemoteGateway();

  Future<void> upsertExpense({
    required Expense row,
    required String householdId,
  }) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      throw StateError('Cannot upsert expense without auth session');
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
  Future<List<Map<String, dynamic>>> fetchExpensesSince({
    required String householdId,
    required int sinceUpdatedAtMs,
  }) async {
    final c = Supabase.instance.client;
    final List<dynamic> raw;
    if (sinceUpdatedAtMs <= 0) {
      raw = await c.from('expenses').select().eq('household_id', householdId).order('updated_at', ascending: true) as List<dynamic>;
    } else {
      raw = await c
          .from('expenses')
          .select()
          .eq('household_id', householdId)
          .gt('updated_at', sinceUpdatedAtMs)
          .order('updated_at', ascending: true) as List<dynamic>;
    }
    return raw.map((e) => Map<String, dynamic>.from(e as Map)).toList(growable: false);
  }
}
