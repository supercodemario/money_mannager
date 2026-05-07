import 'package:flutter/material.dart';
import 'package:money_manager/app/app_services.dart';
import 'package:money_manager/app/cloud_sync_controller.dart';
import 'package:money_manager/data/local/app_database.dart';
import 'package:money_manager/data/remote/supabase_env.dart';
import 'package:money_manager/features/shell/view/app_shell.dart';
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

class MyApp extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final app = MaterialApp(
      title: AppStrings.appTitle,
      theme: AppTheme.light(),
      home: const AppShell(),
    );
    return AppServices(
      db: db,
      cloudSync: cloudSync,
      child: enableSyncLifecycle ? SyncLifecycle(child: app) : app,
    );
  }
}
