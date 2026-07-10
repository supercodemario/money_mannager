import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:money_manager/bootstrap_exports.dart';
import 'package:money_manager/core/navigation/route_registry.dart';
import 'package:money_manager/data/remote/household_remote_gateway.dart';
import 'package:money_manager/data/repositories/expense_repository.dart';
import 'package:money_manager/features/add_expense/models/expense_category/expense_category.dart';

part 'app_router.gr.dart';

@AutoRouterConfig(replaceInRouteName: 'Screen,Route')
class AppRouter extends RootStackRouter {
  AppRouter({super.navigatorKey});

  @override
  List<AutoRoute> get routes => RouteRegistry.routes();
}
