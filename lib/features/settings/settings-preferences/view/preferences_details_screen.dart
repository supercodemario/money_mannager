import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money_manager/app/app_router.dart';
import 'package:money_manager/app/app_services.dart';
import 'package:money_manager/features/settings/settings-preferences/bloc/preferences_details_cubit.dart';
import 'package:money_manager/features/settings/settings-preferences/data/preferences_details_repository.dart';
import 'package:money_manager/features/settings/settings-preferences/models/preferences_details_state/preferences_details_state.dart';
import 'package:money_manager/features/settings/settings-preferences/widgets/preference_dropdown.dart';
import 'package:money_manager/share/share.dart';

@RoutePage()
class PreferencesDetailsScreen extends StatelessWidget {
  const PreferencesDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final services = AppServices.of(context);
    return BlocProvider(
      create: (_) => PreferencesDetailsCubit(
        PreferencesDetailsRepository(
          preferences: services.preferences,
          profiles: services.profiles,
          cloudSync: services.cloudSync,
          household: services.household,
        ),
      )..load(),
      child: const _PreferencesDetailsBody(),
    );
  }
}

class _PreferencesDetailsBody extends StatelessWidget {
  const _PreferencesDetailsBody();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return BlocConsumer<PreferencesDetailsCubit, PreferencesDetailsState>(
      listenWhen: (prev, curr) =>
          curr.householdSaveError != null &&
          curr.householdSaveError != prev.householdSaveError,
      listener: (context, state) {
        final msg = state.householdSaveError;
        if (msg == null) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
      },
      builder: (context, state) {
        final cubit = context.read<PreferencesDetailsCubit>();
        return switch (state.phase) {
          PreferencesDetailsPhase.loading => const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
          PreferencesDetailsPhase.error => Scaffold(
              appBar: AppBar(title: const Text(AppStrings.preferencesDetailsTitle)),
              body: Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.s24),
                  child: Text(
                    AppStrings.profileDetailsLoadError,
                    textAlign: TextAlign.center,
                    style: textTheme.bodyLarge?.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
            ),
          PreferencesDetailsPhase.ready => Scaffold(
              appBar: AppBar(title: const Text(AppStrings.preferencesDetailsTitle)),
              body: ListView(
                padding: const EdgeInsets.all(AppSpacing.s16),
                children: [
                  Text(
                    AppStrings.preferencesRegionalSection,
                    style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: AppSpacing.s8),
                  AppCard(
                    padding: const EdgeInsets.all(AppSpacing.s16),
                    borderRadius: AppRadius.xl,
                    child: Column(
                      children: [
                        PreferenceDropdown(
                          label: AppStrings.preferencesCurrencyLabel,
                          value: state.currency,
                          options: PreferencesDetailsState.currencies,
                          onChanged: cubit.setCurrency,
                        ),
                        const SizedBox(height: AppSpacing.s12),
                        PreferenceDropdown(
                          label: AppStrings.preferencesLanguageLabel,
                          value: state.language,
                          options: PreferencesDetailsState.languages,
                          onChanged: cubit.setLanguage,
                        ),
                        const SizedBox(height: AppSpacing.s12),
                        PreferenceDropdown(
                          label: AppStrings.preferencesNumberFormatLabel,
                          value: state.numberFormat,
                          options: PreferencesDetailsState.numberFormats,
                          onChanged: cubit.setNumberFormat,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s20),
                  Text(
                    AppStrings.preferencesExpenseScopeSection,
                    style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: AppSpacing.s8),
                  AppCard(
                    padding: const EdgeInsets.all(AppSpacing.s16),
                    borderRadius: AppRadius.xl,
                    child: state.households.isEmpty
                        ? Text(
                            AppStrings.preferencesDefaultHouseholdNoOptions,
                            style: textTheme.bodySmall?.copyWith(
                              color: AppColors.onSurfaceVariant,
                            ),
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                AppStrings.preferencesDefaultHouseholdHint,
                                style: textTheme.bodySmall?.copyWith(
                                  color: AppColors.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.s12),
                              PreferenceDropdown(
                                label: AppStrings.preferencesDefaultHouseholdLabel,
                                value: state.defaultHouseholdId ??
                                    state.households.first.householdId,
                                options: state.households
                                    .map((h) => h.householdId)
                                    .toList(),
                                optionLabel: (id) {
                                  final row = state.households.firstWhere(
                                    (h) => h.householdId == id,
                                    orElse: () => state.households.first,
                                  );
                                  if (row.isPersonal) {
                                    return AppStrings.preferencesDefaultHouseholdSelf;
                                  }
                                  return row.name;
                                },
                                onChanged: cubit.setDefaultHousehold,
                              ),
                            ],
                          ),
                  ),
                  const SizedBox(height: AppSpacing.s20),
                  Text(
                    AppStrings.preferencesCategorySection,
                    style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: AppSpacing.s8),
                  AppCard(
                    padding: const EdgeInsets.all(AppSpacing.s16),
                    borderRadius: AppRadius.xl,
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.category_outlined),
                      title: const Text(AppStrings.preferencesManageCategories),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        context.router.push<void>(const CategoryManagementRoute());
                      },
                    ),
                  ),
                ],
              ),
            ),
        };
      },
    );
  }
}
