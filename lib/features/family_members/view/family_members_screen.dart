import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money_manager/app/app_services.dart';
import 'package:money_manager/app/household_flow_scope.dart';
import 'package:money_manager/data/remote/household_remote_gateway.dart';
import 'package:money_manager/features/family_members/bloc/family_members_cubit.dart';
import 'package:money_manager/features/family_members/data/family_members_repository.dart';
import 'package:money_manager/features/family_members/models/family_members_state/family_members_state.dart';
import 'package:money_manager/share/share.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Members of one household, filtered by [householdId] from [household_members].
@RoutePage()
class FamilyMembersScreen extends StatelessWidget {
  const FamilyMembersScreen({
    super.key,
    required this.householdId,
    required this.householdName,
  });

  final String householdId;
  final String householdName;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => FamilyMembersCubit(
        FamilyMembersRepository(AppServices.of(context).household),
        householdId: householdId,
      )..load(),
      child: _FamilyMembersScaffold(householdName: householdName),
    );
  }
}

class _FamilyMembersScaffold extends StatelessWidget {
  const _FamilyMembersScaffold({required this.householdName});

  final String householdName;

  Future<void> _onAddMember(BuildContext context) async {
    final scanned = await HouseholdFlowScope.of(context).pushHouseholdScanDefault(context);
    if (!context.mounted || scanned == null || scanned.isEmpty) return;

    final uid = Supabase.instance.client.auth.currentUser?.id;
    final invitee = scanned.trim();
    if (uid != null && invitee == uid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.familyInviteSelfError)),
      );
      return;
    }

    final cubit = context.read<FamilyMembersCubit>();
    final result = await cubit.addMember(invitee);

    if (!context.mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    switch (result) {
      case AddHouseholdMemberResult.success:
        messenger.showSnackBar(const SnackBar(content: Text(AppStrings.familyInviteSuccess)));
        await cubit.load();
      case AddHouseholdMemberResult.alreadyMember:
        messenger.showSnackBar(const SnackBar(content: Text(AppStrings.familyInviteAlreadyMember)));
      case AddHouseholdMemberResult.notOwner:
        messenger.showSnackBar(const SnackBar(content: Text(AppStrings.familyInviteNotOwner)));
      case AddHouseholdMemberResult.notAuthenticated:
      case AddHouseholdMemberResult.cannotInviteSelf:
        messenger.showSnackBar(const SnackBar(content: Text(AppStrings.familyInviteSelfError)));
      case AddHouseholdMemberResult.personalHouseholdNotShareable:
        messenger.showSnackBar(
          const SnackBar(content: Text(AppStrings.familyPersonalNoInvite)),
        );
      case AddHouseholdMemberResult.inviteeNotCloudUser:
        messenger.showSnackBar(
          const SnackBar(content: Text(AppStrings.familyInviteInvalidAuthUser)),
        );
      case AddHouseholdMemberResult.error:
        messenger.showSnackBar(const SnackBar(content: Text(AppStrings.familyInviteGenericError)));
    }
  }

  Future<void> _showHouseholdQr(BuildContext context) async {
    final cubit = context.read<FamilyMembersCubit>();
    await HouseholdFlowScope.of(context).showHouseholdQrDialog(
      context,
      householdId: cubit.householdId,
      householdName: householdName,
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(householdName),
        actions: [
          BlocBuilder<FamilyMembersCubit, FamilyMembersState>(
            buildWhen: (a, b) => a.phase != b.phase,
            builder: (context, state) {
              if (state.phase != FamilyMembersPhase.ready) return const SizedBox.shrink();
              if (state.isPersonal) return const SizedBox.shrink();
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.qr_code_2_rounded),
                    tooltip: AppStrings.familyShareHouseholdQrTooltip,
                    onPressed: () => _showHouseholdQr(context),
                  ),
                  IconButton(
                    icon: const Icon(Icons.qr_code_scanner_rounded),
                    tooltip: AppStrings.familyScanOtherQrTooltip,
                    onPressed: () => _onAddMember(context),
                  ),
                ],
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<FamilyMembersCubit, FamilyMembersState>(
        builder: (context, state) {
          if (state.phase == FamilyMembersPhase.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.phase == FamilyMembersPhase.error) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.s24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      AppStrings.familyListLoadError,
                      textAlign: TextAlign.center,
                      style: textTheme.bodyLarge?.copyWith(color: AppColors.onSurfaceVariant),
                    ),
                    const SizedBox(height: AppSpacing.s16),
                    FilledButton(
                      onPressed: () => context.read<FamilyMembersCubit>().load(),
                      child: const Text(AppStrings.cloudSyncRefreshCloudData),
                    ),
                  ],
                ),
              ),
            );
          }

          final uid = Supabase.instance.client.auth.currentUser?.id;
          final members = state.members;
          final isOwner = state.isOwner;
          final isPersonal = state.isPersonal;

          return CustomScrollView(
            slivers: [
              if (members.length < 2)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.s16,
                      AppSpacing.s12,
                      AppSpacing.s16,
                      0,
                    ),
                    child: Material(
                      color: AppColors.tertiaryContainer.withValues(alpha: 0.55),
                      borderRadius: BorderRadius.circular(AppRadius.r12),
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.s12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.info_outline_rounded, color: AppColors.tertiaryDim, size: 22),
                            const SizedBox(width: AppSpacing.s8),
                            Expanded(
                              child: Text(
                                AppStrings.familyValidationMinTwoMembers,
                                style: textTheme.bodySmall?.copyWith(
                                  color: AppColors.onSurface,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              if (!isPersonal)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.s16,
                      AppSpacing.s16,
                      AppSpacing.s16,
                      AppSpacing.s12,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        FilledButton.icon(
                          icon: const Icon(Icons.qr_code_scanner_rounded),
                          label: const Text(AppStrings.familyScanOtherQrButton),
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: AppSpacing.s14),
                          ),
                          onPressed: () => _onAddMember(context),
                        ),
                        const SizedBox(height: AppSpacing.s12),
                        Text(
                          AppStrings.familyScanOtherQrSubtitle,
                          style: textTheme.bodySmall?.copyWith(color: AppColors.onSurfaceVariant),
                          textAlign: TextAlign.center,
                        ),
                        if (!isOwner) ...[
                          const SizedBox(height: AppSpacing.s12),
                          Text(
                            AppStrings.familyScanQrOwnerNote,
                            style: textTheme.labelSmall?.copyWith(color: AppColors.tertiaryDim),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              if (members.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.s24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            AppStrings.familyDetailsEmptyTitle,
                            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: AppSpacing.s8),
                          Text(
                            AppStrings.familyDetailsEmptySubtitle,
                            style: textTheme.bodyMedium?.copyWith(color: AppColors.onSurfaceVariant),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(AppSpacing.s16, 0, AppSpacing.s16, AppSpacing.s24),
                  sliver: SliverList.separated(
                    itemCount: members.length,
                    separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.s8),
                    itemBuilder: (context, i) {
                      final m = members[i];
                      final isSelf = uid != null && m.userId == uid;
                      final roleLabel =
                          m.isOwner ? AppStrings.familyDetailsOwnerLabel : AppStrings.familyDetailsMemberLabel;
                      return AppCard(
                        padding: const EdgeInsets.all(AppSpacing.s16),
                        borderRadius: AppRadius.xl,
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${m.userId}${isSelf ? AppStrings.familyDetailsYouSuffix : ''}',
                                    style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                                  ),
                                  const SizedBox(height: AppSpacing.s4),
                                  Text(
                                    roleLabel,
                                    style: textTheme.labelSmall?.copyWith(
                                      color: AppColors.onSurfaceVariant,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
