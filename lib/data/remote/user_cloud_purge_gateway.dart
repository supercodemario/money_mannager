import 'package:supabase_flutter/supabase_flutter.dart';

/// Deletes the signed-in user's rows in Supabase `public` tables (RLS permitting).
/// Must run **before** removing [household_members] rows, or expense/recurring deletes fail.
class UserCloudPurgeGateway {
  UserCloudPurgeGateway();

  Future<void> purgeAllMyPublicData() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      throw StateError('not_signed_in');
    }
    final uid = user.id;
    final c = Supabase.instance.client;

    await c.rpc<void>('cancel_all_my_family_invites');

    await c.from('recurring_payments').delete().eq('auth_user_id', uid);
    await c.from('expenses').delete().eq('auth_user_id', uid);
    await c
        .from('expense_profile_preferences')
        .delete()
        .eq('auth_user_id', uid);
    await c.from('household_members').delete().eq('user_id', uid);
  }
}
