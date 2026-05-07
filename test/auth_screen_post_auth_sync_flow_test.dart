import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money_manager/app/app_services.dart';
import 'package:money_manager/app/cloud_sync_controller.dart';
import 'package:money_manager/data/local/app_database.dart';
import 'package:money_manager/data/remote/sync_constants.dart';
import 'package:money_manager/data/repositories/expense_repository.dart';
import 'package:money_manager/data/repositories/user_profile_repository.dart';
import 'package:money_manager/features/auth/view/auth_screen.dart';
import 'package:money_manager/features/auth/view/post_login_cloud_sync_screen.dart';
import 'package:money_manager/share/share.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class _FakeCloudSyncController extends CloudSyncController {
  Session? _session;

  @override
  bool get isSupabaseConfigured => true;

  @override
  Session? get session => _session;

  @override
  bool get syncAllowed => _session != null;

  @override
  Future<void> signInWithPassword({required String email, required String password}) async {
    _session = Session(
      accessToken: 'token',
      tokenType: 'bearer',
      user: User(
        id: 'user-1',
        appMetadata: const {},
        userMetadata: const {},
        aud: 'authenticated',
        email: email,
        createdAt: DateTime.now().toIso8601String(),
      ),
    );
    notifyListeners();
  }

  @override
  Future<void> signUpWithPassword({required String email, required String password}) async {
    await signInWithPassword(email: email, password: password);
  }

  @override
  Future<void> signOut() async {
    _session = null;
    notifyListeners();
  }
}

class _AuthHost extends StatelessWidget {
  const _AuthHost();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: FilledButton(
          onPressed: () {
            Navigator.of(context).push<void>(
              MaterialPageRoute<void>(
                builder: (_) => const AuthScreen(),
              ),
            );
          },
          child: const Text('open-auth'),
        ),
      ),
    );
  }
}

void main() {
  test('memory insert yields local_only for auth fake cloud', () async {
    final db = AppDatabase.memory();
    addTearDown(db.close);
    final cloud = _FakeCloudSyncController();
    final expenses = ExpenseRepository(db, UserProfileRepository(db), cloud);
    await expenses.insertExpense(
      amountMinor: 1200,
      currencyCode: 'USD',
      categoryId: 'grocery',
      occurredAt: DateTime.now(),
    );
    expect(
      await expenses.countBySyncStatuses({SyncStatusValue.localOnly}),
      1,
    );
  });

  Future<void> _pumpHost(
    WidgetTester tester, {
    required AppDatabase db,
    required CloudSyncController cloud,
  }) async {
    await tester.pumpWidget(
      AppServices(
        db: db,
        cloudSync: cloud,
        child: const MaterialApp(home: _AuthHost()),
      ),
    );
  }

  Future<void> _openAndSubmitSignIn(WidgetTester tester) async {
    await tester.tap(find.text('open-auth'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.enterText(find.byType(TextField).at(0), 'test@example.com');
    await tester.enterText(find.byType(TextField).at(1), 'password123');
    await tester.tap(find.widgetWithText(FilledButton, AppStrings.cloudSyncSignIn));
    await tester.pump();
  }

  testWidgets('pushes post-login sync when local-only count is positive', (tester) async {
    final db = AppDatabase.memory();
    final cloud = _FakeCloudSyncController();
    addTearDown(db.close);

    final expenses = ExpenseRepository(db, UserProfileRepository(db), cloud);
    await expenses.insertExpense(
      amountMinor: 1200,
      currencyCode: 'USD',
      categoryId: 'grocery',
      occurredAt: DateTime.now(),
    );

    await tester.pumpWidget(
      AppServices(
        db: db,
        cloudSync: cloud,
        child: MaterialApp(
          home: Builder(
            builder: (context) {
              return Scaffold(
                body: Center(
                  child: FilledButton(
                    onPressed: () async {
                      final localOnly = await expenses.countBySyncStatuses({
                        SyncStatusValue.localOnly,
                      });
                      if (!context.mounted) return;
                      await Navigator.of(context).push<void>(
                        MaterialPageRoute<void>(
                          builder: (_) => PostLoginCloudSyncScreen(
                            totalRows: localOnly,
                            runSync: (_) async {},
                          ),
                        ),
                      );
                    },
                    child: const Text('push-sync'),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );

    await tester.tap(find.text('push-sync'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pumpAndSettle(const Duration(seconds: 2));

    expect(find.text(AppStrings.cloudSyncPostAuthTitle), findsOneWidget);
    expect(find.text(AppStrings.cloudSyncPostAuthPromptBody(1)), findsOneWidget);
  });

  testWidgets('keeps normal flow when no local-only rows exist', (tester) async {
    final db = AppDatabase.memory();
    final cloud = _FakeCloudSyncController();
    addTearDown(db.close);

    await _pumpHost(tester, db: db, cloud: cloud);
    await _openAndSubmitSignIn(tester);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle(const Duration(seconds: 3));

    expect(find.text('open-auth'), findsOneWidget);
    expect(find.byType(AuthScreen), findsNothing);
    expect(find.text(AppStrings.cloudSyncPostAuthTitle), findsNothing);
  });
}
