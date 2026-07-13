import 'package:auto_route/auto_route.dart';
import 'package:money_manager/app/app_router.dart';

List<AutoRoute> dashboardRoutes() => [
      AutoRoute(page: MonthDaySpendListingRoute.page),
      AutoRoute(page: DaySpendDetailRoute.page),
    ];
