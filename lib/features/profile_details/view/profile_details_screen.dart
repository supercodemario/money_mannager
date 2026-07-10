import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money_manager/app/app_services.dart';
import 'package:money_manager/core/logging/app_log.dart';
import 'package:money_manager/features/profile_details/bloc/profile_details_cubit.dart';
import 'package:money_manager/features/profile_details/data/profile_details_repository.dart';
import 'package:money_manager/features/profile_details/models/profile_details_state/profile_details_state.dart';
import 'package:money_manager/share/share.dart';

@RoutePage()
class ProfileDetailsScreen extends StatelessWidget {
  const ProfileDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final services = AppServices.of(context);
    return BlocProvider(
      create: (_) => ProfileDetailsCubit(
        ProfileDetailsRepository(profiles: services.profiles, db: services.db),
        services,
      )..load(),
      child: const _ProfileDetailsBody(),
    );
  }
}

class _ProfileDetailsBody extends StatefulWidget {
  const _ProfileDetailsBody();

  @override
  State<_ProfileDetailsBody> createState() => _ProfileDetailsBodyState();
}

class _ProfileDetailsBodyState extends State<_ProfileDetailsBody> {
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _editDisplayName(
    BuildContext context,
    ProfileDetailsCubit cubit,
  ) async {
    final profile = cubit.state.profile;
    if (profile == null) return;

    _nameController.text = profile.displayName;

    final res = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(AppStrings.displayNameLabel),
          content: TextField(
            controller: _nameController,
            autofocus: true,
            textInputAction: TextInputAction.done,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(AppStrings.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, _nameController.text),
              child: const Text(AppStrings.save),
            ),
          ],
        );
      },
    );

    final name = res?.trim();
    if (name == null || name.isEmpty || !context.mounted) return;
    await cubit.updateDisplayName(name);
  }

  Future<void> _confirmDelete(
    BuildContext context,
    ProfileDetailsCubit cubit,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(AppStrings.profileDetailsDeleteConfirmTitle),
          content: const Text(AppStrings.profileDetailsDeleteConfirmBody),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text(AppStrings.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: AppColors.onError,
              ),
              child: const Text(AppStrings.profileDetailsDeleteConfirmButton),
            ),
          ],
        );
      },
    );
    if (confirmed != true || !context.mounted) return;
    try {
      await cubit.deleteLocalDataConfirmed(context);
    } catch (e, st) {
      logAppError('profile_details.clear_all_ui', e, st);
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('$e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final cloud = AppServices.of(context).cloudSync;

    return BlocBuilder<ProfileDetailsCubit, ProfileDetailsState>(
      builder: (context, state) {
        final cubit = context.read<ProfileDetailsCubit>();

        late final Widget body;
        switch (state.phase) {
          case ProfileDetailsPhase.loading:
            body = const Center(child: CircularProgressIndicator());
            break;
          case ProfileDetailsPhase.error:
            body = Center(
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
            );
            break;
          case ProfileDetailsPhase.ready:
            final profile = state.profile!;
            body = ListenableBuilder(
              listenable: cloud,
              builder: (context, _) {
                final showSignOut =
                    cloud.isSupabaseConfigured && cloud.session != null;
                return ListView(
                  padding: const EdgeInsets.all(AppSpacing.s16),
                  children: [
                    Text(
                      AppStrings.displayNameLabel,
                      style: textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s4),
                    Text(
                      profile.displayName,
                      style: textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s24),
                    Center(
                      child: Semantics(
                        label: AppStrings.profileDetailsAvatarSemanticsLabel,
                        child: MemberAvatar(
                          userId: cubit.avatarUserId(profile),
                          size: 120,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s24),
                    const CloudSyncSettingsSection(),
                    const SizedBox(height: AppSpacing.s20),
                    if (showSignOut)
                      OutlinedButton(
                        onPressed: state.busy
                            ? null
                            : () => cubit.signOut(context),
                        child: Text(AppStrings.profileDetailsSignOut),
                      ),
                    if (showSignOut) const SizedBox(height: AppSpacing.s12),
                    TextButton(
                      onPressed: state.busy
                          ? null
                          : () => _confirmDelete(context, cubit),
                      child: Text(
                        AppStrings.profileDetailsDeleteLocalData,
                        style: textTheme.labelLarge?.copyWith(
                          color: AppColors.error,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                );
              },
            );
            break;
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text(AppStrings.profileDetailsTitle),
            actions: [
              if (state.phase == ProfileDetailsPhase.ready &&
                  state.profile != null)
                TextButton(
                  onPressed: state.busy
                      ? null
                      : () => _editDisplayName(context, cubit),
                  child: const Text(AppStrings.edit),
                ),
            ],
          ),
          body: body,
        );
      },
    );
  }
}
