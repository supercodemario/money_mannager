import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money_manager/app/app_router.dart';
import 'package:money_manager/app/app_services.dart';
import 'package:money_manager/app/cloud_sync_controller.dart';
import 'package:money_manager/data/local/app_database.dart';
import 'package:money_manager/data/remote/sync_constants.dart';
import 'package:money_manager/data/repositories/expense_repository.dart';
import 'package:money_manager/data/repositories/user_profile_repository.dart';
import 'package:money_manager/features/auth/view/auth_screen.dart';
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

  testWidgets('AuthRoute hosts signed-in auth screen via AppRouter', (tester) async {
    final db = AppDatabase.memory();
    final cloud = _FakeCloudSyncController(signedIn: true);
    addTearDown(db.close);
    final router = AppRouter();

    await tester.pumpWidget(
      AppServices(
        db: db,
        cloudSync: cloud,
        child: MaterialApp.router(
          routerConfig: router.config(
            deepLinkBuilder: (_) => DeepLink.single(const AuthRoute()),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.byType(AuthScreen), findsOneWidget);
    expect(find.text(AppStrings.cloudSyncRefreshCloudData), findsOneWidget);
  });
}
