import 'package:flutter_bloc/flutter_bloc.dart';

/// UI-only flow today; cubit reserved for future state (e.g. share analytics).
class HouseholdQrShareCubit extends Cubit<int> {
  HouseholdQrShareCubit() : super(0);
}
