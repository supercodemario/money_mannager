import 'package:flutter/material.dart';
import 'package:money_manager/app/app_services.dart';
import 'package:money_manager/app/cloud_sync_controller.dart';
import 'package:money_manager/data/remote/sync_constants.dart';
import 'package:money_manager/features/auth/view/post_login_cloud_sync_screen.dart';
import 'package:money_manager/features/auth/view/sync_before_logout_screen.dart';
import 'package:money_manager/share/share.dart';
import 'package:money_manager/sync/sync_orchestrator.dart';

/// Full-screen Supabase email/password sign-in and sign-up.
/// Uses [CloudSyncController] from [AppServices] only (no direct Supabase imports here).
class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _busy = false;
  bool _createAccountMode = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cloud = AppServices.of(context).cloudSync;
    final textTheme = Theme.of(context).textTheme;

    if (!cloud.isSupabaseConfigured) {
      return Scaffold(
        appBar: AppBar(title: const Text(AppStrings.authScreenTitle)),
        body: Padding(
          padding: const EdgeInsets.all(AppSpacing.s16),
          child: Text(
            AppStrings.cloudSyncNotConfigured,
            style: textTheme.bodyMedium?.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.authScreenTitle)),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: cloud,
          builder: (context, _) {
            if (cloud.session != null) {
              return Padding(
                padding: const EdgeInsets.all(AppSpacing.s16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      '${AppStrings.cloudSyncSignedIn}: ${cloud.session!.user.email ?? '—'}',
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (cloud.syncAllowed)
                      Padding(
                        padding: const EdgeInsets.only(top: AppSpacing.s8),
                        child: Text(
                          AppStrings.cloudSyncSyncReady,
                          style: textTheme.labelLarge?.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    const Spacer(),
                    FilledButton.tonal(
                      onPressed: _busy ? null : () => _signOut(cloud),
                      child: Text(AppStrings.cloudSyncSignOut),
                    ),
                    const SizedBox(height: AppSpacing.s8),
                    FilledButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text(AppStrings.commonDone),
                    ),
                  ],
                ),
              );
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.s16),
              child: AutofillGroup(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      AppStrings.authScreenSubtitle,
                      style: textTheme.bodyMedium?.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s24),
                    Text(
                      _createAccountMode
                          ? AppStrings.cloudSyncNeedAccountHint
                          : AppStrings.cloudSyncSignIn,
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s12),
                    TextField(
                      controller: _email,
                      decoration: const InputDecoration(
                        labelText: AppStrings.cloudSyncEmailLabel,
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      autofillHints: const [AutofillHints.email],
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: AppSpacing.s12),
                    TextField(
                      controller: _password,
                      decoration: const InputDecoration(
                        labelText: AppStrings.cloudSyncPasswordLabel,
                        border: OutlineInputBorder(),
                      ),
                      obscureText: true,
                      autofillHints: const [AutofillHints.password],
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) =>
                          _createAccountMode ? _signUp(cloud) : _signIn(cloud),
                    ),
                    const SizedBox(height: AppSpacing.s24),
                    FilledButton(
                      onPressed: _busy
                          ? null
                          : () => _createAccountMode
                                ? _signUp(cloud)
                                : _signIn(cloud),
                      child: Text(
                        _createAccountMode
                            ? AppStrings.cloudSyncCreateAccount
                            : AppStrings.cloudSyncSignIn,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s8),
                    TextButton(
                      onPressed: _busy
                          ? null
                          : () => setState(
                              () => _createAccountMode = !_createAccountMode,
                            ),
                      child: Text(
                        _createAccountMode
                            ? AppStrings.cloudSyncSignIn
                            : AppStrings.cloudSyncCreateAccount,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _signIn(CloudSyncController cloud) async {
    final services = AppServices.of(context);
    final email = _email.text.trim();
    final password = _password.text;
    if (email.isEmpty || password.isEmpty) return;
    setState(() => _busy = true);
    try {
      await cloud.signInWithPassword(email: email, password: password);
      if (!mounted) return;
      final allowClose = await _handlePostAuthSyncScreen(services);
      if (mounted && allowClose) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('$e')));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _signUp(CloudSyncController cloud) async {
    final services = AppServices.of(context);
    final email = _email.text.trim();
    final password = _password.text;
    if (email.isEmpty || password.isEmpty) return;
    setState(() => _busy = true);
    try {
      await cloud.signUpWithPassword(email: email, password: password);
      if (mounted) {
        if (cloud.session != null) {
          final allowClose = await _handlePostAuthSyncScreen(services);
          if (mounted && allowClose) {
            Navigator.of(context).pop();
            return;
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(AppStrings.cloudSyncAccountCreatedSnackbar),
            ),
          );
          setState(() => _createAccountMode = false);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('$e')));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _signOut(CloudSyncController cloud) async {
    final services = AppServices.of(context);
    setState(() => _busy = true);
    try {
      final unsynced = await services.expenses.countUnsynced();
      if (!mounted) return;
      if (unsynced > 0) {
        setState(() => _busy = false);
        await Navigator.of(context).push<void>(
          MaterialPageRoute<void>(
            builder: (_) => SyncBeforeLogoutScreen(
              runSync: (onStage) => _runManualSync(
                services,
                includeLocalOnly: true,
                includeError: true,
                onStage: onStage,
              ),
              onSyncSuccess: () async {
                await _performLogoutAndWipe(services, cloud);
                if (mounted) Navigator.of(context).pop();
              },
              onLogoutWithoutSync: () async {
                await _performLogoutAndWipe(services, cloud);
                if (mounted) Navigator.of(context).pop();
              },
            ),
          ),
        );
        if (mounted && cloud.session == null) {
          Navigator.of(context).pop();
        }
        return;
      }
      await _performLogoutAndWipe(services, cloud);
      if (mounted) Navigator.of(context).pop();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<bool> _handlePostAuthSyncScreen(AppServices services) async {
    final localOnly = await services.expenses.countBySyncStatuses({
      SyncStatusValue.localOnly,
    });
    if (!mounted || localOnly <= 0) return true;
    final shouldClose =
        await Navigator.of(context).push<bool>(
          MaterialPageRoute<bool>(
            builder: (_) => PostLoginCloudSyncScreen(
              totalRows: localOnly,
              runSync: (onStage) => _runManualSync(
                services,
                includeLocalOnly: true,
                includeError: false,
                onStage: onStage,
              ),
            ),
          ),
        ) ??
        false;
    return shouldClose;
  }

  Future<void> _runManualSync(
    AppServices services, {
    required bool includeLocalOnly,
    required bool includeError,
    void Function(ManualSyncStage stage)? onStage,
  }) async {
    final o = SyncOrchestrator(
      db: services.db,
      cloud: services.cloudSync,
      expenses: services.expenses,
    );
    await o.runManualSync(
      includeLocalOnly: includeLocalOnly,
      includeError: includeError,
      failFast: true,
      onStage: onStage,
    );
  }

  Future<void> _performLogoutAndWipe(
    AppServices services,
    CloudSyncController cloud,
  ) async {
    await cloud.signOut();
    await services.db.wipeLocalData();
  }
}
