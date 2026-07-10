import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:money_manager/app/app_router.dart';
import 'package:money_manager/core/navigation/profile_details_navigation.dart';

class AppProfileDetailsNavigation implements ProfileDetailsNavigation {
  @override
  Future<void> pushProfileDetails(BuildContext context) {
    return context.router.push<void>(const ProfileDetailsRoute());
  }
}
