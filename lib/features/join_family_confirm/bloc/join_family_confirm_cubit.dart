import 'package:money_manager/core/navigation/app_route_pop.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money_manager/data/remote/household_remote_gateway.dart';
import 'package:money_manager/features/join_family_confirm/data/join_family_confirm_repository.dart';
import 'package:money_manager/share/share.dart';

class JoinFamilyConfirmCubit extends Cubit<bool> {
  JoinFamilyConfirmCubit(this._repo, this.preview) : super(false);

  final JoinFamilyConfirmRepository _repo;
  final FamilyInvitePreview preview;

  Future<void> confirm(BuildContext context) async {
    emit(true);
    final r = await _repo.accept(preview.householdId);
    if (!context.mounted) return;
    emit(false);

    final messenger = ScaffoldMessenger.of(context);
    switch (r) {
      case AcceptFamilyInviteResult.success:
        messenger.showSnackBar(const SnackBar(content: Text(AppStrings.familyAcceptInviteSuccess)));
        context.popRoute(true);
      case AcceptFamilyInviteResult.inviteNotFound:
        messenger.showSnackBar(
          const SnackBar(content: Text(AppStrings.familyAcceptInviteNotFound)),
        );
        context.popRoute(false);
      case AcceptFamilyInviteResult.cannotAcceptOwnInvite:
        messenger.showSnackBar(
          const SnackBar(content: Text(AppStrings.familyAcceptInviteOwnInvite)),
        );
        context.popRoute(false);
      case AcceptFamilyInviteResult.householdExists:
        messenger.showSnackBar(
          const SnackBar(content: Text(AppStrings.familyAcceptInviteHouseholdExists)),
        );
        context.popRoute(false);
      case AcceptFamilyInviteResult.notAuthenticated:
        messenger.showSnackBar(
          const SnackBar(content: Text(AppStrings.familyDetailsSignInRequired)),
        );
        context.popRoute(false);
      case AcceptFamilyInviteResult.error:
        messenger.showSnackBar(
          const SnackBar(content: Text(AppStrings.familyAcceptInviteGenericError)),
        );
        context.popRoute(false);
    }
  }
}
