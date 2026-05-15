import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Supabase configuration: values from [assets/env/supabase.env] (loaded at runtime) with
/// optional `--dart-define` fallback when a key is missing or empty.
///
/// Call [loadDotEnv] once after [WidgetsFlutterBinding.ensureInitialized].
///
/// Dart-define example (CI or overrides):
/// `flutter run --dart-define=SUPABASE_URL=https://xxx.supabase.co --dart-define=SUPABASE_ANON_KEY=eyJ...`
class SupabaseEnv {
  SupabaseEnv._();

  static const String _assetFile = 'assets/env/supabase.env';

  /// Loads bundled `assets/env/supabase.env`. Missing or empty file is ignored ([isOptional]).
  static Future<void> loadDotEnv() async {
    await dotenv.load(fileName: _assetFile, isOptional: true);
  }

  /// Prefer `.env` after [loadDotEnv]; otherwise `SUPABASE_URL` from `--dart-define`.
  static String get url {
    if (dotenv.isInitialized) {
      final v = dotenv.env['SUPABASE_URL']?.trim();
      if (v != null && v.isNotEmpty) return v;
    }
    return const String.fromEnvironment('SUPABASE_URL', defaultValue: '');
  }

  /// Prefer `.env` after [loadDotEnv]; otherwise `SUPABASE_ANON_KEY` from `--dart-define`.
  static String get anonKey {
    if (dotenv.isInitialized) {
      final v = dotenv.env['SUPABASE_ANON_KEY']?.trim();
      if (v != null && v.isNotEmpty) return v;
    }
    return const String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: '');
  }

  static bool get isConfigured => url.isNotEmpty && anonKey.isNotEmpty;
}
