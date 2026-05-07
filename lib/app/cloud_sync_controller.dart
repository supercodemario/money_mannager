import 'package:flutter/foundation.dart';
import 'package:money_manager/data/local/sync_metadata_store.dart';
import 'package:money_manager/data/remote/auth_remote_gateway.dart';
import 'package:money_manager/data/remote/supabase_env.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

/// Session + Supabase readiness for sync. Used by repositories and [SyncOrchestrator].
/// Feature UI talks to this via [AppServices], not to `lib/data/remote` directly.
class CloudSyncController extends ChangeNotifier {
  CloudSyncController({AuthRemoteGateway? auth}) : _auth = auth ?? AuthRemoteGateway();

  final AuthRemoteGateway _auth;

  bool _bootstrapComplete = false;
  bool _supabaseInitialized = false;
  Session? _session;

  bool get isSupabaseConfigured => SupabaseEnv.isConfigured;

  /// True when Supabase is initialized and the user has a valid session.
  bool get syncAllowed => _bootstrapComplete && _supabaseInitialized && _session != null;

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
  }

  Future<void> signInWithPassword({required String email, required String password}) async {
    await _auth.signInWithPassword(email: email, password: password);
    // `onAuthStateChange` may emit after this await; sync reads `syncAllowed` immediately.
    if (_supabaseInitialized) {
      _session = Supabase.instance.client.auth.currentSession;
      notifyListeners();
    }
  }

  Future<void> signUpWithPassword({required String email, required String password}) async {
    await _auth.signUpWithPassword(email: email, password: password);
    if (_supabaseInitialized) {
      _session = Supabase.instance.client.auth.currentSession;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    _session = null;
    notifyListeners();
    await SyncMetadataStore.clearAll();
  }

  /// Creates a household + membership on first successful sync after sign-in.
  Future<void> ensureHouseholdIfNeeded() async {
    if (!syncAllowed) return;
    final existing = await SyncMetadataStore.getHouseholdId();
    if (existing != null) return;

    final uid = Supabase.instance.client.auth.currentUser!.id;

    // After logout we clear local metadata; reuse the user's existing household in
    // Postgres so pulls still see rows uploaded under the previous household id.
    final memberRows = await Supabase.instance.client
        .from('household_members')
        .select('household_id')
        .eq('user_id', uid)
        .limit(1) as List<dynamic>;
    if (memberRows.isNotEmpty) {
      final hid = (memberRows.first as Map<String, dynamic>)['household_id'] as String;
      await SyncMetadataStore.setHouseholdId(hid);
      return;
    }

    final hid = const Uuid().v4();
    await Supabase.instance.client.from('households').insert(<String, dynamic>{
      'id': hid,
      'name': 'Home',
    });
    await Supabase.instance.client.from('household_members').insert(<String, dynamic>{
      'household_id': hid,
      'user_id': uid,
    });
    await SyncMetadataStore.setHouseholdId(hid);
  }
}
