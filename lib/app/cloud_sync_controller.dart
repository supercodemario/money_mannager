import 'package:flutter/foundation.dart';
import 'package:money_manager/core/logging/app_log.dart';
import 'package:money_manager/data/local/sync_metadata_store.dart';
import 'package:money_manager/data/remote/auth_remote_gateway.dart';
import 'package:money_manager/data/remote/household_remote_gateway.dart';
import 'package:money_manager/data/remote/supabase_env.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Session + Supabase readiness for sync. Used by repositories and [SyncOrchestrator].
/// Feature UI talks to this via [AppServices], not to `lib/data/remote` directly.
class CloudSyncController extends ChangeNotifier {
  CloudSyncController({
    AuthRemoteGateway? auth,
    HouseholdRemoteGateway? household,
  }) : _auth = auth ?? AuthRemoteGateway(),
       _household = household ?? HouseholdRemoteGateway();

  final AuthRemoteGateway _auth;
  final HouseholdRemoteGateway _household;

  bool _bootstrapComplete = false;
  bool _supabaseInitialized = false;
  Session? _session;

  bool get isSupabaseConfigured => SupabaseEnv.isConfigured;

  /// True when Supabase is initialized and the user has a valid session.
  bool get syncAllowed =>
      _bootstrapComplete && _supabaseInitialized && _session != null;

  Session? get session => _session;

  Future<void> initialize() async {
    if (!SupabaseEnv.isConfigured) {
      _bootstrapComplete = true;
      notifyListeners();
      return;
    }

    await Supabase.initialize(
      url: SupabaseEnv.url,
      anonKey: SupabaseEnv.anonKey,
    );
    _supabaseInitialized = true;
    _session = Supabase.instance.client.auth.currentSession;
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      _session = data.session;
      notifyListeners();
    });
    _bootstrapComplete = true;
    notifyListeners();
    if (syncAllowed) {
      await ensurePersonalHousehold();
    }
  }

  Future<void> signInWithPassword({
    required String email,
    required String password,
  }) async {
    await _auth.signInWithPassword(email: email, password: password);
    if (_supabaseInitialized) {
      _session = Supabase.instance.client.auth.currentSession;
      notifyListeners();
      await ensurePersonalHousehold();
    }
  }

  Future<void> signUpWithPassword({
    required String email,
    required String password,
  }) async {
    await _auth.signUpWithPassword(email: email, password: password);
    if (_supabaseInitialized) {
      _session = Supabase.instance.client.auth.currentSession;
      notifyListeners();
      await ensurePersonalHousehold();
    }
  }

  Future<String?> ensurePersonalHousehold() async {
    if (!syncAllowed) return null;
    return _household.ensurePersonalHousehold();
  }

  /// Persists default expense household when [householdId] is valid for the session.
  ///
  /// Returns false when not signed in, not a member, or membership could not be verified.
  Future<bool> setDefaultExpenseHousehold(String householdId) async {
    if (!syncAllowed) return false;
    final member = await checkHouseholdMembership(householdId);
    if (member != true) return false;
    await SyncMetadataStore.setDefaultExpenseHouseholdId(householdId);
    return true;
  }

  Future<void> signOut() async {
    await _auth.signOut();
    _session = null;
    notifyListeners();
    await SyncMetadataStore.clearAll();
  }

  /// Ensures personal household exists and default expense household preference is valid.
  ///
  /// Does **not** set a single-household sync scope; cloud pull uses RLS across all memberships.
  Future<void> ensureDefaultExpenseHouseholdPreference() async {
    if (!syncAllowed) return;
    await ensurePersonalHousehold();

    final preferred = await SyncMetadataStore.getDefaultExpenseHouseholdId();
    if (preferred != null) {
      final member = await checkHouseholdMembership(preferred);
      if (member == true) return;
      if (member == null) return;
      await SyncMetadataStore.clearDefaultExpenseHouseholdId();
      if (kDebugMode) {
        debugPrint(
          '[sync] clearing stale default_expense_household_id: $preferred',
        );
      }
    }

    final personalHouseholdId = await _household.ensurePersonalHousehold();
    if (personalHouseholdId != null) {
      await SyncMetadataStore.setDefaultExpenseHouseholdId(personalHouseholdId);
      return;
    }

    final uid = Supabase.instance.client.auth.currentUser?.id;
    if (uid == null) return;
    final memberRows =
        await Supabase.instance.client
                .from('household_members')
                .select('household_id')
                .eq('user_id', uid)
                .limit(1)
            as List<dynamic>;
    if (memberRows.isNotEmpty) {
      final hid =
          (memberRows.first as Map<String, dynamic>)['household_id'] as String;
      await SyncMetadataStore.setDefaultExpenseHouseholdId(hid);
    }
  }

  /// @deprecated Use [ensureDefaultExpenseHouseholdPreference].
  Future<void> ensureHouseholdIfNeeded() =>
      ensureDefaultExpenseHouseholdPreference();

  /// `true` = member, `false` = not a member, `null` = check failed (e.g. network).
  Future<bool?> checkHouseholdMembership(String householdId) async {
    if (!syncAllowed) return false;
    final uid = Supabase.instance.client.auth.currentUser?.id;
    if (uid == null) return false;
    try {
      final memberRows =
          await Supabase.instance.client
                  .from('household_members')
                  .select('household_id')
                  .eq('user_id', uid)
                  .eq('household_id', householdId)
                  .limit(1)
              as List<dynamic>;
      return memberRows.isNotEmpty;
    } catch (e, st) {
      logAppError('cloud_sync.household_membership_check', e, st);
      return null;
    }
  }
}
