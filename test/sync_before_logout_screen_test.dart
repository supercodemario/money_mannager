import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money_manager/features/auth/view/sync_before_logout_screen.dart';
import 'package:money_manager/share/share.dart';
import 'package:money_manager/sync/sync_orchestrator.dart';

void main() {
  testWidgets('Retry reruns sync and success callback', (tester) async {
    var attempts = 0;
    var successCalled = false;
    await tester.pumpWidget(
      MaterialApp(
        home: SyncBeforeLogoutScreen(
          runSync: (onStage) async {
            attempts++;
            onStage(ManualSyncStage.preparing);
            if (attempts == 1) {
              throw Exception('network down');
            }
          },
          onSyncSuccess: () async {
            successCalled = true;
          },
          onLogoutWithoutSync: () async {},
        ),
      ),
    );

    await tester.pump();
    await tester.pump();
    expect(find.text(AppStrings.cloudSyncSyncBeforeLogoutFailureTitle), findsOneWidget);

    await tester.tap(find.text(AppStrings.cloudSyncRetry));
    await tester.pump();
    await tester.pump();

    expect(attempts, 2);
    expect(successCalled, isTrue);
  });

  testWidgets('Logout without sync action is available on failure', (tester) async {
    var logoutWithoutSyncCalled = false;
    await tester.pumpWidget(
      MaterialApp(
        home: SyncBeforeLogoutScreen(
          runSync: (onStage) async => throw Exception('still failing'),
          onSyncSuccess: () async {},
          onLogoutWithoutSync: () async {
            logoutWithoutSyncCalled = true;
          },
        ),
      ),
    );

    await tester.pump();
    await tester.pump();
    expect(find.text(AppStrings.cloudSyncLogoutWithoutSync), findsOneWidget);

    await tester.tap(find.text(AppStrings.cloudSyncLogoutWithoutSync));
    await tester.pump();
    expect(logoutWithoutSyncCalled, isTrue);
  });
}
