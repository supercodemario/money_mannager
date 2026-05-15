import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money_manager/core/logging/app_log.dart';
import 'package:money_manager/features/create_family/data/create_family_repository.dart';
import 'package:money_manager/features/create_family/models/create_family_state/create_family_state.dart';
import 'package:money_manager/share/share.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CreateFamilyCubit extends Cubit<CreateFamilyState> {
  CreateFamilyCubit(this._repo, {required String inviteId}) : super(CreateFamilyState.initial(inviteId));

  final CreateFamilyRepository _repo;

  Future<void> register(String name) async {
    if (name.isEmpty) {
      emit(state.copyWith(errorText: AppStrings.familyCreateNameRequired));
      return;
    }
    emit(state.copyWith(busy: true, clearError: true));
    try {
      await _repo.registerFamilyInvite(inviteId: state.inviteId, displayName: name);
      emit(state.copyWith(busy: false, registered: true, clearError: true));
    } on PostgrestException catch (e, st) {
      logAppError('create_family.register', e, st);
      final msg = e.message.toLowerCase();
      emit(
        state.copyWith(
          busy: false,
          errorText: msg.contains('invite_id_taken') || msg.contains('household_id_taken')
              ? AppStrings.familyCreateInviteIdTaken
              : AppStrings.familyCreateRegisterError,
        ),
      );
    } catch (e, st) {
      logAppError('create_family.register', e, st);
      emit(state.copyWith(busy: false, errorText: AppStrings.familyCreateRegisterError));
    }
  }

  Future<bool> updateName(String name) async {
    if (!state.registered) return false;
    if (name.isEmpty) {
      emit(state.copyWith(errorText: AppStrings.familyCreateNameRequired));
      return false;
    }
    emit(state.copyWith(busy: true, clearError: true));
    try {
      await _repo.updateFamilyInviteName(inviteId: state.inviteId, displayName: name);
      emit(state.copyWith(busy: false));
      return true;
    } catch (e, st) {
      logAppError('create_family.update_name', e, st);
      emit(state.copyWith(busy: false, errorText: AppStrings.familyCreateUpdateError));
      return false;
    }
  }

  Future<void> cancelInvite(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(AppStrings.familyCreateCancelInviteConfirmTitle),
        content: const Text(AppStrings.familyCreateCancelInviteConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(AppStrings.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(AppStrings.familyCreateCancelInviteButton),
          ),
        ],
      ),
    );
    if (ok != true) return;
    emit(state.copyWith(busy: true));
    try {
      await _repo.cancelFamilyInvite(state.inviteId);
      emit(state.copyWith(busy: false, registered: false));
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(AppStrings.familyCreateCancelSuccess)),
        );
        Navigator.of(context).pop();
      }
    } catch (e, st) {
      logAppError('create_family.cancel_invite', e, st);
      emit(state.copyWith(busy: false, errorText: AppStrings.familyCreateCancelError));
    }
  }
}
