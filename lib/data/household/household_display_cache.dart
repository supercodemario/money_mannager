import 'package:money_manager/data/remote/household_remote_gateway.dart';
import 'package:money_manager/share/tokens/app_strings.dart';

/// Display label for a household on expense rows.
class HouseholdDisplayInfo {
  const HouseholdDisplayInfo({
    required this.label,
    required this.isPersonal,
  });

  final String label;
  final bool isPersonal;
}

/// In-memory map of household id → display info for the signed-in user.
class HouseholdDisplayCache {
  HouseholdDisplayCache._();

  static Map<String, HouseholdDisplayInfo>? _cached;

  static Future<Map<String, HouseholdDisplayInfo>> load(
    HouseholdRemoteGateway gateway,
  ) async {
    final households = await gateway.fetchHouseholdsForCurrentUser();
    final map = <String, HouseholdDisplayInfo>{};
    for (final h in households) {
      map[h.householdId] = HouseholdDisplayInfo(
        label: h.isPersonal
            ? AppStrings.preferencesDefaultHouseholdSelf
            : h.name,
        isPersonal: h.isPersonal,
      );
    }
    _cached = map;
    return map;
  }

  static Map<String, HouseholdDisplayInfo>? get cached => _cached;

  static void clear() => _cached = null;

  static String labelFor(
    String? householdId,
    Map<String, HouseholdDisplayInfo> labelsByHouseholdId,
  ) {
    if (householdId == null || householdId.isEmpty) return '';
    return labelsByHouseholdId[householdId]?.label ??
        AppStrings.expenseUnknownHousehold;
  }
}
