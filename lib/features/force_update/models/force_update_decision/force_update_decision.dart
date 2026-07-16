import 'package:money_manager/features/force_update/models/force_update_policy/force_update_policy.dart';

enum ForceUpdateOutcome { allow, force }

/// Result of comparing the installed build to the effective minimum.
class ForceUpdateDecision {
  const ForceUpdateDecision.allow()
      : outcome = ForceUpdateOutcome.allow,
        policy = null;

  const ForceUpdateDecision.force(this.policy) : outcome = ForceUpdateOutcome.force;

  final ForceUpdateOutcome outcome;
  final ForceUpdatePolicy? policy;

  bool get mustUpdate => outcome == ForceUpdateOutcome.force;
}
