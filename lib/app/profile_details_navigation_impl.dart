import 'package:flutter/material.dart';
import 'package:money_manager/core/navigation/profile_details_navigation.dart';
import 'package:money_manager/features/profile_details/view/profile_details_screen.dart';

class AppProfileDetailsNavigation implements ProfileDetailsNavigation {
  @override
  Future<void> pushProfileDetails(BuildContext context) {
    return Navigator.of(context).push<void>(
      MaterialPageRoute<void>(builder: (_) => const ProfileDetailsScreen()),
    );
  }
}
