import 'package:money_manager/data/local/app_database.dart';
import 'package:money_manager/data/remote/sync_constants.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Remote recurring payment rows — only called from [SyncOrchestrator].
///
/// Pull queries rely on RLS membership policies. Push uses each row's [householdId].
class RecurringRemoteGateway {
  RecurringRemoteGateway();

  Future<void> upsertTemplate({required RecurringPayment row}) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      throw StateError('Cannot upsert recurring template without auth session');
    }
    final householdId = row.householdId;
    if (householdId == null || householdId.isEmpty) {
      throw StateError(
        'Cannot upsert recurring template without household_id on row ${row.id}',
      );
    }

    await Supabase.instance.client
        .from('recurring_payments')
        .upsert(<String, dynamic>{
          'id': row.id,
          'household_id': householdId,
          'auth_user_id': user.id,
          'title': row.title,
          'category_id': row.categoryId,
          'amount_minor_suggested': row.amountMinorSuggested,
          'currency_code': row.currencyCode,
          'day_of_month': row.dayOfMonth,
          'end_month_key': row.endMonthKey,
          'is_enabled': row.isEnabled,
          'is_deleted': row.isDeleted,
          'created_at': row.createdAt,
          'updated_at': row.updatedAt,
          'remote_id': row.remoteId ?? row.id,
          'sync_status': SyncStatusValue.synced,
          'server_updated_at': DateTime.now().millisecondsSinceEpoch,
        });
  }

  Future<void> upsertOccurrence({
    required RecurringPaymentOccurrence row,
    required String householdId,
  }) async {
    if (householdId.isEmpty) {
      throw StateError(
        'Cannot upsert recurring occurrence without household_id for ${row.id}',
      );
    }
    await Supabase.instance.client
        .from('recurring_payment_occurrences')
        .upsert(<String, dynamic>{
          'id': row.id,
          'household_id': householdId,
          'recurring_payment_id': row.recurringPaymentId,
          'month_key': row.monthKey,
          'expense_id': row.expenseId,
          'is_deleted': row.isDeleted,
          'created_at': row.createdAt,
          'updated_at': row.updatedAt,
          'remote_id': row.remoteId ?? row.id,
          'sync_status': SyncStatusValue.synced,
          'server_updated_at': DateTime.now().millisecondsSinceEpoch,
        });
  }

  Future<List<Map<String, dynamic>>> fetchTemplatesSince({
    required int sinceUpdatedAtMs,
  }) async {
    final query = Supabase.instance.client.from('recurring_payments').select();
    final List<dynamic> raw = sinceUpdatedAtMs <= 0
        ? await query.order('updated_at', ascending: true) as List<dynamic>
        : await query
                  .gt('updated_at', sinceUpdatedAtMs)
                  .order('updated_at', ascending: true)
              as List<dynamic>;
    return raw
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList(growable: false);
  }

  /// Fetches one template by id (RLS-scoped). Used when an expense references a
  /// template that was not included in the incremental [fetchTemplatesSince] window.
  Future<Map<String, dynamic>?> fetchTemplateById(String id) async {
    final raw = await Supabase.instance.client
        .from('recurring_payments')
        .select()
        .eq('id', id)
        .maybeSingle();
    if (raw == null) return null;
    return Map<String, dynamic>.from(raw);
  }

  Future<List<Map<String, dynamic>>> fetchOccurrencesSince({
    required int sinceUpdatedAtMs,
  }) async {
    final query = Supabase.instance.client
        .from('recurring_payment_occurrences')
        .select();
    final List<dynamic> raw = sinceUpdatedAtMs <= 0
        ? await query.order('updated_at', ascending: true) as List<dynamic>
        : await query
                  .gt('updated_at', sinceUpdatedAtMs)
                  .order('updated_at', ascending: true)
              as List<dynamic>;
    return raw
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList(growable: false);
  }
}
