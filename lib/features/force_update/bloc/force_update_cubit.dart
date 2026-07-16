import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money_manager/features/force_update/models/force_update_decision/force_update_decision.dart';

/// Holds the latest force-update decision for tests / future UI hooks.
class ForceUpdateCubit extends Cubit<ForceUpdateDecision?> {
  ForceUpdateCubit() : super(null);

  void setDecision(ForceUpdateDecision? decision) => emit(decision);
}
