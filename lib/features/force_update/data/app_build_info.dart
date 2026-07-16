import 'package:package_info_plus/package_info_plus.dart';

/// Reads the installed app build number (Android `versionCode`).
class AppBuildInfo {
  const AppBuildInfo();

  Future<int> readBuildNumber() async {
    final info = await PackageInfo.fromPlatform();
    return int.tryParse(info.buildNumber) ?? 0;
  }
}
