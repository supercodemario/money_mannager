import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money_manager/app/app_services.dart';
import 'package:money_manager/features/create_family/bloc/create_family_cubit.dart';
import 'package:money_manager/features/create_family/data/create_family_repository.dart';
import 'package:money_manager/features/create_family/models/create_family_state/create_family_state.dart';
import 'package:money_manager/share/share.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:uuid/uuid.dart';

/// Registers a pending invite ([family_invites]) with a new UUID; household is created when
/// someone else accepts via the join confirm flow.
class CreateFamilyScreen extends StatelessWidget {
  const CreateFamilyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CreateFamilyCubit(
        CreateFamilyRepository(AppServices.of(context).household),
        inviteId: Uuid().v4(),
      ),
      child: const _CreateFamilyForm(),
    );
  }
}

class _CreateFamilyForm extends StatefulWidget {
  const _CreateFamilyForm();

  @override
  State<_CreateFamilyForm> createState() => _CreateFamilyFormState();
}

class _CreateFamilyFormState extends State<_CreateFamilyForm> {
  final _nameController = TextEditingController(text: 'Family');

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.familyCreateTitle),
        actions: [
          BlocBuilder<CreateFamilyCubit, CreateFamilyState>(
            buildWhen: (a, b) => a.registered != b.registered,
            builder: (context, state) {
              if (!state.registered) return const SizedBox.shrink();
              return TextButton(
                onPressed: state.busy ? null : () => context.read<CreateFamilyCubit>().cancelInvite(context),
                child: const Text(AppStrings.familyCreateCancelInviteButton),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.s24),
          child: BlocBuilder<CreateFamilyCubit, CreateFamilyState>(
            builder: (context, state) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: AppStrings.familyCreateNameLabel,
                      border: OutlineInputBorder(),
                    ),
                    textCapitalization: TextCapitalization.words,
                    enabled: !state.busy,
                  ),
                  if (state.errorText != null) ...[
                    const SizedBox(height: AppSpacing.s8),
                    Text(
                      state.errorText!,
                      style: textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.error),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.s16),
                  if (!state.registered)
                    FilledButton(
                      onPressed: state.busy
                          ? null
                          : () => context.read<CreateFamilyCubit>().register(_nameController.text.trim()),
                      child: state.busy
                          ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text(AppStrings.familyCreateSubmitButton),
                    ),
                  if (state.registered) ...[
                    Text(
                      AppStrings.familyCreateQrHelp,
                      style: textTheme.bodyMedium?.copyWith(color: AppColors.onSurfaceVariant),
                    ),
                    const SizedBox(height: AppSpacing.s16),
                    Center(
                      child: QrImageView(
                        key: ValueKey<String>('create-family-${state.inviteId}'),
                        data: state.inviteId,
                        version: QrVersions.auto,
                        size: 220,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s12),
                    SelectableText(state.inviteId),
                    const SizedBox(height: AppSpacing.s20),
                    OutlinedButton(
                      onPressed: state.busy
                          ? null
                          : () async {
                              final ok = await context
                                  .read<CreateFamilyCubit>()
                                  .updateName(_nameController.text.trim());
                              if (!context.mounted) return;
                              if (ok) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text(AppStrings.familyCreateUpdateSuccess)),
                                );
                              }
                            },
                      child: const Text(AppStrings.familyCreateUpdateNameButton),
                    ),
                  ],
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
