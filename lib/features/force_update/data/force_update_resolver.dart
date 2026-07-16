import 'package:money_manager/features/force_update/models/force_update_decision/force_update_decision.dart';
import 'package:money_manager/features/force_update/models/force_update_policy/force_update_policy.dart';

/// Resolves whether the installed build must update (cached fail-open).
class ForceUpdateResolver {
  const ForceUpdateResolver();

  /// Pure decision helper for tests and [resolve].
  ForceUpdateDecision decide({
    required int localBuild,
    required ForceUpdatePolicy? policy,
  }) {
    if (policy == null) return const ForceUpdateDecision.allow();
    if (localBuild < policy.minBuild) {
      return ForceUpdateDecision.force(policy);
    }
    return const ForceUpdateDecision.allow();
  }

  Future<ForceUpdateDecision> resolve({
    required Future<ForceUpdatePolicy?> Function() fetchRemote,
    required Future<ForceUpdatePolicy?> Function() readCache,
    required Future<void> Function(ForceUpdatePolicy policy) writeCache,
    required Future<int> Function() readLocalBuild,
  }) async {
    final localBuild = await readLocalBuild();
    if (localBuild <= 0) return const ForceUpdateDecision.allow();

    ForceUpdatePolicy? policy;
    try {
      policy = await fetchRemote();
      if (policy != null) {
        await writeCache(policy);
      }
    } catch (_) {
      policy = null;
    }

    policy ??= await readCache();
    return decide(localBuild: localBuild, policy: policy);
  }
}
