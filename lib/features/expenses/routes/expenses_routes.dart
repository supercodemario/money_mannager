import 'package:auto_route/auto_route.dart';
import 'package:money_manager/app/app_router.dart';

List<AutoRoute> expensesRoutes() => [
      AutoRoute(page: AddRecurringPaymentRoute.page),
      AutoRoute(page: MonthlyCategoryDetailRoute.page),
    ];
