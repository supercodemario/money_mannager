import 'package:money_manager/core/logging/app_log.dart';
import 'package:money_manager/data/remote/supabase_env.dart';
import 'package:money_manager/features/force_update/models/force_update_policy/force_update_policy.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Reads Android force-update policy from Supabase (anon-readable).
class ForceUpdateRemote {
  ForceUpdateRemote({SupabaseClient? client}) : _client = client;

  final SupabaseClient? _client;

  static const platformAndroid = 'android';

  SupabaseClient? get _effectiveClient {
    if (_client != null) return _client;
    if (!SupabaseEnv.isConfigured) return null;
    try {
      return Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

  Future<ForceUpdatePolicy?> fetchAndroidPolicy() async {
    final client = _effectiveClient;
    if (client == null) return null;

    try {
      final row = await client
          .from('app_version_policy')
          .select('min_build, store_url, message')
          .eq('platform', platformAndroid)
          .maybeSingle();
      if (row == null) return null;

      final minBuildRaw = row['min_build'];
      final storeUrl = row['store_url']?.toString();
      if (minBuildRaw == null || storeUrl == null || storeUrl.isEmpty) return null;

      final minBuild = minBuildRaw is int
          ? minBuildRaw
          : int.tryParse(minBuildRaw.toString());
      if (minBuild == null || minBuild < 1) return null;

      final messageRaw = row['message']?.toString();
      return ForceUpdatePolicy(
        minBuild: minBuild,
        storeUrl: storeUrl,
        message: (messageRaw == null || messageRaw.isEmpty) ? null : messageRaw,
      );
    } catch (e, st) {
      logAppError('force_update.fetch_android_policy', e, st);
      return null;
    }
  }
}
