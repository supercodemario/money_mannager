import 'package:auto_route/auto_route.dart';
import 'package:money_manager/app/app_router.dart';

List<AutoRoute> authRoutes() => [
      AutoRoute(page: AuthRoute.page),
      AutoRoute(page: PostLoginCloudSyncRoute.page),
      AutoRoute(page: SyncBeforeLogoutRoute.page),
    ];
