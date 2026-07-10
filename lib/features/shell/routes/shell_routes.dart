import 'package:auto_route/auto_route.dart';
import 'package:money_manager/app/app_router.dart';

List<AutoRoute> shellRoutes() => [
      AutoRoute(page: AppShellRoute.page, initial: true),
      AutoRoute(page: QuickAddRoute.page),
    ];
