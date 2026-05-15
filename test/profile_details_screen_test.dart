import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money_manager/app/app_services.dart';
import 'package:money_manager/app/cloud_sync_controller.dart';
import 'package:money_manager/app/profile_details_navigation_impl.dart';
import 'package:money_manager/app/profile_details_scope.dart';
import 'package:money_manager/data/local/app_database.dart';
import 'package:money_manager/data/repositories/user_profile_repository.dart';
import 'package:money_manager/features/profile_details/view/profile_details_screen.dart';
import 'package:money_manager/features/settings/view/settings_screen.dart';
import 'package:money_manager/share/tokens/app_strings.dart';
import 'package:money_manager/share/widgets/member_avatar.dart';

void main() {
  testWidgets(
    'ProfileDetailsScreen shows display name, avatar, cloud sync; no QR',
    (WidgetTester tester) async {
      TestWidgetsFlutterBinding.ensureInitialized();

      final cloud = CloudSyncController();
      await cloud.initialize();

      final db = AppDatabase.memory();
      await db.ensureReady();
      final profile = await UserProfileRepository(db).getCurrentProfile();

      await tester.pumpWidget(
        AppServices(
          db: db,
          cloudSync: cloud,
          child: const MaterialApp(home: ProfileDetailsScreen()),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text(profile.displayName), findsOneWidget);

      expect(
        find.byKey(const ValueKey<String>('cloud_sync_settings_section')),
        findsOneWidget,
      );
      expect(find.text(AppStrings.cloudSyncNotConfigured), findsOneWidget);

      expect(find.byType(MemberAvatar), findsOneWidget);
      expect(
        find.byKey(ValueKey<String>('member_avatar_${profile.id}')),
        findsOneWidget,
      );

      expect(
        find.text(AppStrings.profileDetailsDeleteLocalData),
        findsOneWidget,
      );

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(milliseconds: 500));
    },
  );

  testWidgets(
    'SettingsScreen does not embed cloud sync section on root scroll',
    (WidgetTester tester) async {
      TestWidgetsFlutterBinding.ensureInitialized();

      final cloud = CloudSyncController();
      await cloud.initialize();

      final db = AppDatabase.memory();
      await db.ensureReady();

      await tester.pumpWidget(
        AppServices(
          db: db,
          cloudSync: cloud,
          child: ProfileDetailsScope(
            navigation: AppProfileDetailsNavigation(),
            child: const MaterialApp(home: SettingsScreen()),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey<String>('cloud_sync_settings_section')),
        findsNothing,
      );

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(milliseconds: 500));
    },
  );
}
