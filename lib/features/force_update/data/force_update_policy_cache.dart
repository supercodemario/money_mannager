import 'package:shared_preferences/shared_preferences.dart';
import 'package:money_manager/features/force_update/models/force_update_policy/force_update_policy.dart';

/// Device-local cache of the last successful Android force-update policy.
class ForceUpdatePolicyCache {
  ForceUpdatePolicyCache();

  static const _minBuildKey = 'force_update_android_min_build';
  static const _storeUrlKey = 'force_update_android_store_url';
  static const _messageKey = 'force_update_android_message';

  Future<ForceUpdatePolicy?> read() async {
    final p = await SharedPreferences.getInstance();
    final minBuild = p.getInt(_minBuildKey);
    final storeUrl = p.getString(_storeUrlKey);
    if (minBuild == null || storeUrl == null || storeUrl.isEmpty) return null;
    final message = p.getString(_messageKey);
    return ForceUpdatePolicy(
      minBuild: minBuild,
      storeUrl: storeUrl,
      message: (message == null || message.isEmpty) ? null : message,
    );
  }

  Future<void> write(ForceUpdatePolicy policy) async {
    final p = await SharedPreferences.getInstance();
    await p.setInt(_minBuildKey, policy.minBuild);
    await p.setString(_storeUrlKey, policy.storeUrl);
    final message = policy.message;
    if (message == null || message.isEmpty) {
      await p.remove(_messageKey);
    } else {
      await p.setString(_messageKey, message);
    }
  }
}
