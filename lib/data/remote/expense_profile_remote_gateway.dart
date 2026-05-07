import 'package:money_manager/data/local/app_database.dart';
import 'package:money_manager/data/remote/sync_constants.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Remote expense profile preferences — only called from [SyncOrchestrator].
class ExpenseProfileRemoteGateway {
  ExpenseProfileRemoteGateway();

  Future<void> upsertProfile(ExpenseLimitPreference row) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      throw StateError('Cannot upsert expense profile without auth session');
    }

    await Supabase.instance.client
        .from('expense_profile_preferences')
        .upsert(<String, dynamic>{
          'auth_user_id': user.id,
          'monthly_income_minor': row.monthlyIncomeMinor,
          'monthly_savings_minor': row.monthlySavingsMinor,
          'exclude_unpaid_recurring': row.excludeUnpaidRecurring,
          'updated_at': row.updatedAt,
          'sync_status': SyncStatusValue.synced,
          'server_updated_at': DateTime.now().millisecondsSinceEpoch,
        });
  }

  Future<Map<String, dynamic>?> fetchProfile() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      throw StateError('Cannot fetch expense profile without auth session');
    }

    final raw = await Supabase.instance.client
        .from('expense_profile_preferences')
        .select()
        .eq('auth_user_id', user.id)
        .maybeSingle();
    if (raw == null) return null;
    return Map<String, dynamic>.from(raw);
  }

  String get currentAuthUserId {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      throw StateError(
        'Cannot resolve expense profile auth user without auth session',
      );
    }
    return user.id;
  }
}
