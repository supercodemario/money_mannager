import 'package:money_manager/data/local/app_database.dart';
import 'package:money_manager/data/remote/user_cloud_purge_gateway.dart';
import 'package:money_manager/data/repositories/user_profile_repository.dart';

class ProfileDetailsRepository {
  ProfileDetailsRepository({
    required UserProfileRepository profiles,
    required AppDatabase db,
    UserCloudPurgeGateway? cloudPurge,
  }) : _profiles = profiles,
       _db = db,
       _cloudPurge = cloudPurge ?? UserCloudPurgeGateway();

  final UserProfileRepository _profiles;
  final AppDatabase _db;
  final UserCloudPurgeGateway _cloudPurge;

  Future<UserProfile> getCurrentProfile() => _profiles.getCurrentProfile();

  Future<void> updateDisplayName(String displayName) =>
      _profiles.updateDisplayName(displayName);

  Future<void> wipeLocalData() => _db.wipeLocalData();

  Future<void> purgeMyRemotePublicData() => _cloudPurge.purgeAllMyPublicData();
}
