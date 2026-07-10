import 'package:money_manager/core/navigation/app_route_pop.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money_manager/app/app_services.dart';
import 'package:money_manager/core/logging/app_log.dart';
import 'package:money_manager/data/local/app_database.dart';
import 'package:money_manager/features/auth/account_session_flow.dart';
import 'package:money_manager/features/profile_details/data/profile_details_repository.dart';
import 'package:money_manager/features/profile_details/models/profile_details_state/profile_details_state.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileDetailsCubit extends Cubit<ProfileDetailsState> {
  ProfileDetailsCubit(this._repo, this._services)
    : super(const ProfileDetailsState());

  final ProfileDetailsRepository _repo;
  final AppServices _services;

  Future<void> load() async {
    emit(state.copyWith(phase: ProfileDetailsPhase.loading));
    try {
      final p = await _repo.getCurrentProfile();
      if (!isClosed) {
        emit(ProfileDetailsState(phase: ProfileDetailsPhase.ready, profile: p));
      }
    } catch (e, st) {
      logAppError('profile_details.load', e, st);
      if (!isClosed) {
        emit(const ProfileDetailsState(phase: ProfileDetailsPhase.error));
      }
    }
  }

  Future<void> updateDisplayName(String displayName) async {
    await _repo.updateDisplayName(displayName);
    await load();
  }

  String avatarUserId(UserProfile profile) {
    if (_services.cloudSync.syncAllowed) {
      final uid = Supabase.instance.client.auth.currentUser?.id;
      if (uid != null && uid.isNotEmpty) return uid;
    }
    return profile.id;
  }

  Future<void> signOut(BuildContext context) async {
    if (!context.mounted) return;
    emit(state.copyWith(busy: true));
    try {
      final unsynced = await _services.expenses.countUnsynced();
      if (!context.mounted) return;
      if (unsynced > 0) {
        emit(state.copyWith(busy: false));
      }
      await signOutWithSyncBeforeLogout(
        context,
        _services,
        _services.cloudSync,
      );
    } catch (e, st) {
      logAppError('profile_details.sign_out', e, st);
      rethrow;
    } finally {
      if (!isClosed) emit(state.copyWith(busy: false));
    }
  }

  Future<void> deleteLocalDataConfirmed(BuildContext context) async {
    if (!context.mounted) return;
    emit(state.copyWith(busy: true));
    try {
      final cloud = _services.cloudSync;
      if (cloud.session != null) {
        await _repo.purgeMyRemotePublicData();
        await cloud.signOut();
        await _repo.wipeLocalData();
        if (context.mounted) context.popRoute();
      } else {
        await _repo.wipeLocalData();
        if (context.mounted) context.popRoute();
      }
    } catch (e, st) {
      logAppError('profile_details.clear_all', e, st);
      rethrow;
    } finally {
      if (!isClosed) emit(state.copyWith(busy: false));
    }
  }
}
