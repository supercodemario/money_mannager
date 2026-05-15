import 'package:flutter/material.dart';
import 'package:money_manager/core/navigation/profile_details_navigation.dart';

class ProfileDetailsScope extends InheritedWidget {
  const ProfileDetailsScope({
    super.key,
    required this.navigation,
    required super.child,
  });

  final ProfileDetailsNavigation navigation;

  static ProfileDetailsNavigation of(BuildContext context) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<ProfileDetailsScope>();
    assert(
      scope != null,
      'ProfileDetailsScope missing — wrap the app root with ProfileDetailsScope.',
    );
    return scope!.navigation;
  }

  @override
  bool updateShouldNotify(covariant ProfileDetailsScope oldWidget) =>
      navigation != oldWidget.navigation;
}
