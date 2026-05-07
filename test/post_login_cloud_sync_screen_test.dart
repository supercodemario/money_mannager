import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money_manager/features/auth/view/post_login_cloud_sync_screen.dart';
import 'package:money_manager/share/share.dart';
import 'package:money_manager/sync/sync_orchestrator.dart';

void main() {
  testWidgets('defer from idle does not call runSync', (tester) async {
    var calls = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: PostLoginCloudSyncScreen(
          totalRows: 1,
          runSync: (_) async {
            calls++;
          },
        ),
      ),
    );

    await tester.tap(find.text(AppStrings.cloudSyncNotNow));
    await tester.pumpAndSettle();
    expect(calls, 0);
  });

  testWidgets('renders idle count and progresses through sync stages to success', (tester) async {
    final done = Completer<void>();
    late void Function(ManualSyncStage stage) stageCallback;

    await tester.pumpWidget(
      MaterialApp(
        home: PostLoginCloudSyncScreen(
          totalRows: 3,
          runSync: (onStage) async {
            stageCallback = onStage;
            await done.future;
          },
        ),
      ),
    );

    expect(find.text(AppStrings.cloudSyncPostAuthPromptTitle), findsOneWidget);
    expect(find.text(AppStrings.cloudSyncPostAuthPromptBody(3)), findsOneWidget);

    await tester.tap(find.text(AppStrings.cloudSyncSyncNow));
    await tester.pump();
    expect(find.text(AppStrings.cloudSyncPostAuthPreparing), findsOneWidget);

    stageCallback(ManualSyncStage.pushing);
    await tester.pump();
    expect(find.text(AppStrings.cloudSyncPostAuthPushing), findsOneWidget);

    stageCallback(ManualSyncStage.pulling);
    await tester.pump();
    expect(find.text(AppStrings.cloudSyncPostAuthPulling), findsOneWidget);

    done.complete();
    await tester.pump();
    expect(find.text(AppStrings.cloudSyncPostAuthSuccessTitle), findsOneWidget);
    expect(find.text(AppStrings.commonDone), findsOneWidget);
  });

  testWidgets('shows failure, allows retry, and can defer', (tester) async {
    var attempts = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: PostLoginCloudSyncScreen(
          totalRows: 1,
          runSync: (_) async {
            attempts++;
            if (attempts == 1) {
              throw Exception('network error');
            }
          },
        ),
      ),
    );

    await tester.tap(find.text(AppStrings.cloudSyncSyncNow));
    await tester.pump();
    expect(find.text(AppStrings.cloudSyncPostAuthFailureTitle), findsOneWidget);
    expect(find.text(AppStrings.cloudSyncRetry), findsOneWidget);

    await tester.tap(find.text(AppStrings.cloudSyncRetry));
    await tester.pump();
    expect(attempts, 2);
    expect(find.text(AppStrings.cloudSyncPostAuthSuccessTitle), findsOneWidget);
  });

  testWidgets('defer from idle pops true so auth shell can close', (tester) async {
    bool? result;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            return Scaffold(
              body: Center(
                child: FilledButton(
                  onPressed: () async {
                    result = await Navigator.of(context).push<bool>(
                      MaterialPageRoute<bool>(
                        builder: (_) => PostLoginCloudSyncScreen(
                          totalRows: 2,
                          runSync: (_) async {},
                        ),
                      ),
                    );
                  },
                  child: const Text('open'),
                ),
              ),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.tap(find.text(AppStrings.cloudSyncNotNow));
    await tester.pumpAndSettle();

    expect(find.text('open'), findsOneWidget);
    expect(result, isTrue);
  });

  testWidgets('cannot pop while sync is running', (tester) async {
    final blocker = Completer<void>();
    await tester.pumpWidget(
      MaterialApp(
        home: PostLoginCloudSyncScreen(
          totalRows: 1,
          runSync: (_) => blocker.future,
        ),
      ),
    );

    await tester.tap(find.text(AppStrings.cloudSyncSyncNow));
    await tester.pump();

    final popScope = tester.widget<PopScope>(find.byType(PopScope));
    expect(popScope.canPop, isFalse);

    blocker.complete();
    await tester.pumpAndSettle();

    final after = tester.widget<PopScope>(find.byType(PopScope));
    expect(after.canPop, isTrue);
  });
}
