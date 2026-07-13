import 'package:auto_route/auto_route.dart';
import 'package:money_manager/features/auth/routes/auth_routes.dart';
import 'package:money_manager/features/create_family/routes/create_family_routes.dart';
import 'package:money_manager/features/dashboard/routes/dashboard_routes.dart';
import 'package:money_manager/features/expenses/routes/expenses_routes.dart';
import 'package:money_manager/features/family_list/routes/family_list_routes.dart';
import 'package:money_manager/features/family_members/routes/family_members_routes.dart';
import 'package:money_manager/features/household_scan/routes/household_scan_routes.dart';
import 'package:money_manager/features/join_family_confirm/routes/join_family_confirm_routes.dart';
import 'package:money_manager/features/profile_details/routes/profile_details_routes.dart';
import 'package:money_manager/features/settings/routes/settings_routes.dart';
import 'package:money_manager/features/shell/routes/shell_routes.dart';

/// Aggregates feature [AutoRoute] lists for the root [AppRouter].
class RouteRegistry {
  RouteRegistry._();

  static List<AutoRoute> routes() => [
        ...shellRoutes(),
        ...dashboardRoutes(),
        ...settingsRoutes(),
        ...expensesRoutes(),
        ...authRoutes(),
        ...createFamilyRoutes(),
        ...householdScanRoutes(),
        ...joinFamilyConfirmRoutes(),
        ...familyMembersRoutes(),
        ...familyListRoutes(),
        ...profileDetailsRoutes(),
      ];
}
