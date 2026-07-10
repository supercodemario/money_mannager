import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money_manager/app/app_services.dart';
import 'package:money_manager/app/household_flow_scope.dart';
import 'package:money_manager/features/family_list/bloc/family_list_cubit.dart';
import 'package:money_manager/features/family_list/data/family_list_repository.dart';
import 'package:money_manager/features/family_list/models/family_list_state/family_list_state.dart';
import 'package:money_manager/share/share.dart';

/// Lists every household the signed-in user belongs to ([household_members]).
@RoutePage()
class FamilyListScreen extends StatelessWidget {
  const FamilyListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => FamilyListCubit(
        FamilyListRepository(AppServices.of(context).household),
        AppServices.of(context).cloudSync,
        HouseholdFlowScope.of(context),
      )..load(),
      child: const _FamilyListScaffold(),
    );
  }
}

class _FamilyListScaffold extends StatelessWidget {
  const _FamilyListScaffold();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final cubit = context.read<FamilyListCubit>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.familyListTitle),
        actions: [
          BlocBuilder<FamilyListCubit, FamilyListState>(
            buildWhen: (a, b) => a.phase != b.phase,
            builder: (context, state) {
              if (state.phase == FamilyListPhase.signedOut || state.phase == FamilyListPhase.loading) {
                return const SizedBox.shrink();
              }
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.add_rounded),
                    tooltip: AppStrings.familyListCreateFamilyButton,
                    onPressed: () => cubit.openCreateFamily(context),
                  ),
                  IconButton(
                    icon: const Icon(Icons.qr_code_scanner_rounded),
                    tooltip: AppStrings.familyJoinWithQrTooltip,
                    onPressed: () => cubit.scanToJoin(context),
                  ),
                ],
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<FamilyListCubit, FamilyListState>(
        builder: (context, state) {
          if (state.phase == FamilyListPhase.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.phase == FamilyListPhase.signedOut) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.s24),
                child: Text(
                  AppStrings.familyDetailsSignInRequired,
                  textAlign: TextAlign.center,
                  style: textTheme.bodyLarge?.copyWith(color: AppColors.onSurfaceVariant),
                ),
              ),
            );
          }
          if (state.phase == FamilyListPhase.loadError) {
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
                      onPressed: () => context.read<FamilyListCubit>().load(),
                      child: const Text(AppStrings.cloudSyncRefreshCloudData),
                    ),
                    const SizedBox(height: AppSpacing.s12),
                    OutlinedButton.icon(
                      icon: const Icon(Icons.qr_code_scanner_rounded),
                      label: const Text(AppStrings.familyJoinEmptyScanButton),
                      onPressed: () => cubit.scanToJoin(context),
                    ),
                    const SizedBox(height: AppSpacing.s12),
                    OutlinedButton.icon(
                      icon: const Icon(Icons.add_rounded),
                      label: const Text(AppStrings.familyListCreateFamilyButton),
                      onPressed: () => cubit.openCreateFamily(context),
                    ),
                  ],
                ),
              ),
            );
          }

          final households = state.households;
          final syncId = state.syncHouseholdId;

          if (households.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.s24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      AppStrings.familyListEmptyTitle,
                      textAlign: TextAlign.center,
                      style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: AppSpacing.s12),
                    Text(
                      AppStrings.familyListEmptySubtitle,
                      textAlign: TextAlign.center,
                      style: textTheme.bodyMedium?.copyWith(color: AppColors.onSurfaceVariant),
                    ),
                    const SizedBox(height: AppSpacing.s24),
                    FilledButton.icon(
                      icon: const Icon(Icons.add_rounded),
                      label: const Text(AppStrings.familyListCreateFamilyButton),
                      onPressed: () => cubit.openCreateFamily(context),
                    ),
                    const SizedBox(height: AppSpacing.s12),
                    FilledButton.icon(
                      icon: const Icon(Icons.qr_code_scanner_rounded),
                      label: const Text(AppStrings.familyJoinEmptyScanButton),
                      onPressed: () => cubit.scanToJoin(context),
                    ),
                  ],
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => context.read<FamilyListCubit>().load(),
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.s16,
                      AppSpacing.s12,
                      AppSpacing.s16,
                      AppSpacing.s8,
                    ),
                    child: FilledButton.icon(
                      icon: const Icon(Icons.add_rounded),
                      label: const Text(AppStrings.familyListCreateFamilyButton),
                      onPressed: () => cubit.openCreateFamily(context),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.s16,
                    0,
                    AppSpacing.s16,
                    AppSpacing.s24,
                  ),
                  sliver: SliverList.separated(
                    itemCount: households.length,
                    separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.s8),
                    itemBuilder: (context, i) {
                      final h = households[i];
                      final isSyncHousehold = syncId != null && syncId == h.householdId;
                      return Material(
                        color: AppColors.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(AppRadius.xl),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: InkWell(
                                borderRadius: BorderRadius.circular(AppRadius.xl),
                                onTap: () => cubit.openMembers(context, h),
                                child: Padding(
                                  padding: const EdgeInsets.all(AppSpacing.s16),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              h.name,
                                              style: textTheme.titleSmall?.copyWith(
                                                fontWeight: FontWeight.w800,
                                              ),
                                            ),
                                            const SizedBox(height: AppSpacing.s4),
                                            Text(
                                              h.amOwner
                                                  ? AppStrings.familyListYourRoleOwner
                                                  : AppStrings.familyListYourRoleMember,
                                              style: textTheme.bodySmall?.copyWith(
                                                color: AppColors.onSurfaceVariant,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      if (isSyncHousehold)
                                        Padding(
                                          padding: const EdgeInsets.only(right: AppSpacing.s8),
                                          child: Chip(
                                            label: Text(
                                              AppStrings.familyListSyncHouseholdBadge,
                                              style: textTheme.labelSmall?.copyWith(
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                            visualDensity: VisualDensity.compact,
                                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                          ),
                                        ),
                                      Icon(
                                        Icons.chevron_right_rounded,
                                        color: AppColors.onSurfaceVariant,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            if (!h.isPersonal)
                              IconButton(
                                icon: const Icon(Icons.qr_code_2_rounded),
                                tooltip: AppStrings.familyListShowQrTooltip,
                                onPressed: () => cubit.showQrFor(context, h),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
