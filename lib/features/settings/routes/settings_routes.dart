import 'package:auto_route/auto_route.dart';
import 'package:money_manager/app/app_router.dart';

List<AutoRoute> settingsRoutes() => [
      AutoRoute(page: PreferencesDetailsRoute.page),
      AutoRoute(page: ExpenseLimitsRoute.page),
      AutoRoute(page: CategoryManagementRoute.page),
      AutoRoute(page: RecurringTemplatesManagementRoute.page),
    ];
