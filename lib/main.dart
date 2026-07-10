import 'package:flutter/material.dart';
import 'package:money_manager/app/app_router.dart';
import 'package:money_manager/app/app_services.dart';
import 'package:money_manager/app/cloud_sync_controller.dart';
import 'package:money_manager/app/household_flow_navigation_impl.dart';
import 'package:money_manager/app/household_flow_scope.dart';
import 'package:money_manager/app/profile_details_navigation_impl.dart';
import 'package:money_manager/app/profile_details_scope.dart';
import 'package:money_manager/app/regional_material_app_root.dart';
import 'package:money_manager/data/local/app_database.dart';
import 'package:money_manager/data/remote/supabase_env.dart';
import 'package:money_manager/share/share.dart';
import 'package:money_manager/sync/sync_lifecycle.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseEnv.loadDotEnv();
  final cloudSync = CloudSyncController();
  await cloudSync.initialize();
  final db = AppDatabase();
  runApp(MyApp(db: db, cloudSync: cloudSync));
}

class MyApp extends StatefulWidget {
  const MyApp({
    super.key,
    required this.db,
    required this.cloudSync,
    this.enableSyncLifecycle = true,
  });

  final AppDatabase db;
  final CloudSyncController cloudSync;

  /// When false (e.g. widget tests), [SyncOrchestrator] is not started — avoids pump timeouts.
  final bool enableSyncLifecycle;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final AppRouter _appRouter = AppRouter();

  @override
  Widget build(BuildContext context) {
    final app = RegionalMaterialAppRoot(
      title: AppStrings.appTitle,
      theme: AppTheme.light(),
      routerConfig: _appRouter.config(),
    );
    return AppServices(
      db: widget.db,
      cloudSync: widget.cloudSync,
      child: ProfileDetailsScope(
        navigation: AppProfileDetailsNavigation(),
        child: HouseholdFlowScope(
          navigation: AppHouseholdFlowNavigation(),
          child: widget.enableSyncLifecycle ? SyncLifecycle(child: app) : app,
        ),
      ),
    );
  }
}
