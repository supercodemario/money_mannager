import 'package:flutter/foundation.dart';
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
    // `onAuthStateChange` may emit after this await; sync reads `syncAllowed` immediately.
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

  Future<void> setDefaultExpenseHousehold(String householdId) async {
    if (!syncAllowed) return;
    final stillMember = await _currentUserIsMemberOfHousehold(householdId);
    if (!stillMember) return;
    await SyncMetadataStore.setDefaultExpenseHouseholdId(householdId);
    await SyncMetadataStore.setHouseholdId(householdId);
  }


  Future<void> signOut() async {
    await _auth.signOut();
    _session = null;
    notifyListeners();
    await SyncMetadataStore.clearAll();
  }

  /// Resolves the active household id for sync from local cache and/or
  /// `household_members` for the signed-in user. Does **not** insert new
  /// `households` or `household_members` rows (those come from your Supabase
  /// flows only, e.g. `accept_family_invite`, join RPCs, or manual SQL).
  ///
  /// Uses default expense household preference first, then personal household,
  /// then an existing membership fallback for migration safety.
  Future<void> ensureHouseholdIfNeeded() async {
    if (!syncAllowed) return;
    await ensurePersonalHousehold();

    final preferred = await SyncMetadataStore.getDefaultExpenseHouseholdId();
    if (preferred != null) {
      final stillMember = await _currentUserIsMemberOfHousehold(preferred);
      if (stillMember) {
        await SyncMetadataStore.setHouseholdId(preferred);
        return;
      }
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
      await SyncMetadataStore.setHouseholdId(personalHouseholdId);
      return;
    }

    final existing = await SyncMetadataStore.getHouseholdId();
    if (existing != null) {
      final stillMember = await _currentUserIsMemberOfHousehold(existing);
      if (stillMember) {
        await SyncMetadataStore.setDefaultExpenseHouseholdId(existing);
        return;
      }
      await SyncMetadataStore.clearHouseholdId();
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
      await SyncMetadataStore.setHouseholdId(hid);
    }
  }

  Future<bool> _currentUserIsMemberOfHousehold(String householdId) async {
    final uid = Supabase.instance.client.auth.currentUser?.id;
    if (uid == null) return false;
    final memberRows =
        await Supabase.instance.client
                .from('household_members')
                .select('household_id')
                .eq('user_id', uid)
                .eq('household_id', householdId)
                .limit(1)
            as List<dynamic>;
    return memberRows.isNotEmpty;
  }
}
