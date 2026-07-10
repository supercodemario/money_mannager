import 'package:flutter/material.dart';
import 'package:money_manager/app/app_services.dart';
import 'package:money_manager/data/local/app_database.dart';
import 'package:money_manager/share/regional/regional_formatting_data.dart';
import 'package:money_manager/share/regional/regional_formatting_scope.dart';

/// Builds [MaterialApp.router] with `locale`, localization delegates, and
/// [RegionalFormattingScope] driven by [UserPreferencesRepository.watchForUser].
class RegionalMaterialAppRoot extends StatelessWidget {
  const RegionalMaterialAppRoot({
    super.key,
    required this.title,
    required this.theme,
    required this.routerConfig,
  });

  final String title;
  final ThemeData theme;
  final RouterConfig<Object> routerConfig;

  @override
  Widget build(BuildContext context) {
    final services = AppServices.of(context);
    return FutureBuilder<String>(
      future: services.profiles.getCurrentUserId(),
      builder: (context, uidSnap) {
        final uid = uidSnap.data;
        return StreamBuilder<UserPreference?>(
          stream: uid != null
              ? services.preferences.watchForUser(uid)
              : Stream<UserPreference?>.value(null),
          builder: (context, prefSnap) {
            final data = RegionalFormattingData.fromPreference(prefSnap.data);
            return MaterialApp.router(
              title: title,
              theme: theme,
              locale: data.materialLocale,
              supportedLocales: RegionalFormattingData.supportedLocales,
              localizationsDelegates: RegionalFormattingData.localizationsDelegates,
              routerConfig: routerConfig,
              builder: (context, child) => RegionalFormattingScope(
                data: data,
                child: child ?? const SizedBox.shrink(),
              ),
            );
          },
        );
      },
    );
  }
}
