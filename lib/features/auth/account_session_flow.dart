import 'package:auto_route/auto_route.dart';
import 'package:money_manager/core/navigation/app_route_pop.dart';
import 'package:flutter/material.dart';
import 'package:money_manager/app/app_router.dart';
import 'package:money_manager/app/app_services.dart';
import 'package:money_manager/app/cloud_sync_controller.dart';
import 'package:money_manager/sync/manual_sync_helper.dart';

Future<void> performLogoutAndWipe(
  AppServices services,
  CloudSyncController cloud,
) async {
  await cloud.signOut();
  await services.db.wipeLocalData();
}

/// Ends cloud session and wipes local DB (same as primary auth sign-out).
///
/// When [popNavigatorRoute] is true, pops one route after logout if the stack
/// is still mounted and the session is cleared (or immediately when no sync
/// gate was shown).
Future<void> signOutWithSyncBeforeLogout(
  BuildContext context,
  AppServices services,
  CloudSyncController cloud, {
  bool popNavigatorRoute = true,
}) async {
  final router = context.router;
  final unsynced = await services.expenses.countUnsynced();
  if (!context.mounted) return;
  final canSync = unsynced > 0 && await ManualSyncHelper.canRunCloudSync(services);
  if (canSync) {
    await router.push<void>(
      SyncBeforeLogoutRoute(
        runSync: (onStage) => ManualSyncHelper.runLogoutManualSync(
          services,
          onStage: onStage,
        ),
        onSyncSuccess: () async {
          await performLogoutAndWipe(services, cloud);
          if (context.mounted) context.popRoute();
        },
        onLogoutWithoutSync: () async {
          await performLogoutAndWipe(services, cloud);
          if (context.mounted) context.popRoute();
        },
      ),
    );
    if (context.mounted && cloud.session == null && popNavigatorRoute) {
      router.maybePop();
    }
    return;
  }
  await performLogoutAndWipe(services, cloud);
  if (context.mounted && popNavigatorRoute) {
    router.maybePop();
  }
}
