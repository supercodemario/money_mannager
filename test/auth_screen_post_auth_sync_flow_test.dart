import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money_manager/app/app_services.dart';
import 'package:money_manager/app/cloud_sync_controller.dart';
import 'package:money_manager/data/local/app_database.dart';
import 'package:money_manager/data/local/sync_metadata_store.dart';
import 'package:money_manager/data/remote/sync_constants.dart';
import 'package:money_manager/data/repositories/expense_limits_repository.dart';
import 'package:money_manager/data/repositories/expense_repository.dart';
import 'package:money_manager/data/repositories/recurring_payment_repository.dart';
import 'package:money_manager/data/repositories/user_profile_repository.dart';
import 'package:money_manager/features/auth/view/auth_screen.dart';
import 'package:money_manager/features/auth/view/post_login_cloud_sync_screen.dart';
import 'package:money_manager/share/share.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class _FakeCloudSyncController extends CloudSyncController {
  _FakeCloudSyncController({bool signedIn = false}) {
    if (signedIn) {
      _session = _makeSession(email: 'signedin@example.com');
    }
  }

  Session? _session;

  Session _makeSession({required String email}) {
    return Session(
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
  }

  @override
  bool get isSupabaseConfigured => true;

  @override
  Session? get session => _session;

  @override
  bool get syncAllowed => _session != null;

  @override
  Future<void> signInWithPassword({
    required String email,
    required String password,
  }) async {
    _session = _makeSession(email: email);
    notifyListeners();
  }

  @override
  Future<void> signUpWithPassword({
    required String email,
    required String password,
  }) async {
    await signInWithPassword(email: email, password: password);
  }

  @override
  Future<void> signOut() async {
    _session = null;
    notifyListeners();
  }

  @override
  Future<void> ensureHouseholdIfNeeded() async {}
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
              MaterialPageRoute<void>(builder: (_) => const AuthScreen()),
            );
          },
          child: const Text('open-auth'),
        ),
      ),
    );
  }
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

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
    expect(await expenses.countBySyncStatuses({SyncStatusValue.localOnly}), 1);
  });

  Future<void> pumpHost(
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

  Future<void> openAndSubmitSignIn(WidgetTester tester) async {
    await tester.tap(find.text('open-auth'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.enterText(find.byType(TextField).at(0), 'test@example.com');
    await tester.enterText(find.byType(TextField).at(1), 'password123');
    await tester.tap(
      find.widgetWithText(FilledButton, AppStrings.cloudSyncSignIn),
    );
    await tester.pump();
  }

  testWidgets('pushes post-login sync when local-only count is positive', (
    tester,
  ) async {
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
    expect(
      find.text(AppStrings.cloudSyncPostAuthPromptBody(1)),
      findsOneWidget,
    );
  });

  testWidgets('shows post-login bootstrap flow when no local-only rows exist', (
    tester,
  ) async {
    final db = AppDatabase.memory();
    final cloud = _FakeCloudSyncController();
    addTearDown(db.close);

    await pumpHost(tester, db: db, cloud: cloud);
    await openAndSubmitSignIn(tester);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle(const Duration(seconds: 3));

    expect(find.byType(PostLoginCloudSyncScreen), findsOneWidget);
    expect(
      find.text(AppStrings.cloudSyncPostAuthBootstrapBody),
      findsOneWidget,
    );
  });

  testWidgets(
    'post-login sync includes local-only expense profile preferences',
    (tester) async {
      final db = AppDatabase.memory();
      final cloud = _FakeCloudSyncController();
      addTearDown(db.close);
      final profiles = UserProfileRepository(db);
      final expenses = ExpenseRepository(db, profiles, cloud);
      final recurring = RecurringPaymentRepository(db, expenses);
      final limits = ExpenseLimitsRepository(
        db,
        recurring,
        profiles: profiles,
        cloudSync: cloud,
      );
      final uid = await profiles.getCurrentUserId();

      await limits.upsertPreferences(
        userId: uid,
        monthlyIncomeMinor: 120000,
        monthlySavingsMinor: 12000,
        excludeUnpaidRecurring: true,
      );

      await pumpHost(tester, db: db, cloud: cloud);
      await openAndSubmitSignIn(tester);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      expect(find.byType(PostLoginCloudSyncScreen), findsOneWidget);
      expect(
        find.text(AppStrings.cloudSyncPostAuthPromptBody(1)),
        findsOneWidget,
      );
    },
  );

  testWidgets('skips post-login bootstrap flow when already completed', (
    tester,
  ) async {
    final db = AppDatabase.memory();
    final cloud = _FakeCloudSyncController();
    addTearDown(db.close);
    await SyncMetadataStore.setPostAuthBootstrapCompleted(true);

    await pumpHost(tester, db: db, cloud: cloud);
    await openAndSubmitSignIn(tester);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle(const Duration(seconds: 3));

    expect(find.text('open-auth'), findsOneWidget);
    expect(find.byType(AuthScreen), findsNothing);
    expect(find.text(AppStrings.cloudSyncPostAuthTitle), findsNothing);
  });

  testWidgets(
    'signed-in auth screen exposes manual cloud refresh entry point',
    (tester) async {
      final db = AppDatabase.memory();
      final cloud = _FakeCloudSyncController(signedIn: true);
      addTearDown(db.close);

      await tester.pumpWidget(
        AppServices(
          db: db,
          cloudSync: cloud,
          child: const MaterialApp(home: AuthScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.cloudSyncRefreshCloudData), findsOneWidget);

      await tester.tap(find.text(AppStrings.cloudSyncRefreshCloudData));
      await tester.pumpAndSettle();

      expect(find.byType(PostLoginCloudSyncScreen), findsOneWidget);
      expect(
        find.text(AppStrings.cloudSyncPostAuthBootstrapBody),
        findsOneWidget,
      );
    },
  );
}
