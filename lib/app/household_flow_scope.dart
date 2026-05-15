import 'package:flutter/widgets.dart';
import 'package:money_manager/core/navigation/household_flow_navigation.dart';

class HouseholdFlowScope extends InheritedWidget {
  const HouseholdFlowScope({
    super.key,
    required this.navigation,
    required super.child,
  });

  final HouseholdFlowNavigation navigation;

  static HouseholdFlowNavigation of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<HouseholdFlowScope>();
    assert(scope != null, 'HouseholdFlowScope missing — wrap the app root with HouseholdFlowScope.');
    return scope!.navigation;
  }

  static HouseholdFlowNavigation? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<HouseholdFlowScope>()?.navigation;
  }

  @override
  bool updateShouldNotify(covariant HouseholdFlowScope oldWidget) =>
      navigation != oldWidget.navigation;
}
