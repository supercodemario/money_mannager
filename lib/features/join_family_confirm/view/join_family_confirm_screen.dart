import 'package:auto_route/auto_route.dart';
import 'package:money_manager/core/navigation/app_route_pop.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money_manager/app/app_services.dart';
import 'package:money_manager/data/remote/household_remote_gateway.dart';
import 'package:money_manager/features/join_family_confirm/bloc/join_family_confirm_cubit.dart';
import 'package:money_manager/features/join_family_confirm/data/join_family_confirm_repository.dart';
import 'package:money_manager/share/share.dart';

/// Confirms joining a pending [FamilyInvitePreview] (creates [households] on success).
@RoutePage()
class JoinFamilyConfirmScreen extends StatelessWidget {
  const JoinFamilyConfirmScreen({super.key, required this.preview});

  final FamilyInvitePreview preview;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => JoinFamilyConfirmCubit(
        JoinFamilyConfirmRepository(AppServices.of(context).household),
        preview,
      ),
      child: const _JoinFamilyConfirmBody(),
    );
  }
}

class _JoinFamilyConfirmBody extends StatelessWidget {
  const _JoinFamilyConfirmBody();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final preview = context.read<JoinFamilyConfirmCubit>().preview;

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.familyJoinConfirmTitle)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.s24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                AppStrings.familyJoinConfirmBody(preview.displayName),
                style: textTheme.bodyLarge,
              ),
              const Spacer(),
              BlocBuilder<JoinFamilyConfirmCubit, bool>(
                builder: (context, busy) {
                  return FilledButton(
                    onPressed: busy ? null : () => context.read<JoinFamilyConfirmCubit>().confirm(context),
                    child: busy
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text(AppStrings.familyJoinConfirmButton),
                  );
                },
              ),
              const SizedBox(height: AppSpacing.s12),
              BlocBuilder<JoinFamilyConfirmCubit, bool>(
                builder: (context, busy) {
                  return OutlinedButton(
                    onPressed: busy ? null : () => context.popRoute(false),
                    child: const Text(AppStrings.cancel),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
