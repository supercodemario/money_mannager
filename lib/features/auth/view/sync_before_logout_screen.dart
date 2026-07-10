import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:money_manager/core/logging/app_log.dart';
import 'package:money_manager/share/share.dart';
import 'package:money_manager/sync/sync_orchestrator.dart';

typedef LogoutSyncRunner = Future<void> Function(
  void Function(ManualSyncStage stage) onStage,
);

@RoutePage()
class SyncBeforeLogoutScreen extends StatefulWidget {
  const SyncBeforeLogoutScreen({
    super.key,
    required this.runSync,
    required this.onSyncSuccess,
    required this.onLogoutWithoutSync,
  });

  final LogoutSyncRunner runSync;
  final Future<void> Function() onSyncSuccess;
  final Future<void> Function() onLogoutWithoutSync;

  @override
  State<SyncBeforeLogoutScreen> createState() => _SyncBeforeLogoutScreenState();
}

class _SyncBeforeLogoutScreenState extends State<SyncBeforeLogoutScreen> {
  bool _busy = true;
  ManualSyncStage _stage = ManualSyncStage.preparing;
  String? _failure;

  @override
  void initState() {
    super.initState();
    _run();
  }

  Future<void> _run() async {
    setState(() {
      _busy = true;
      _failure = null;
      _stage = ManualSyncStage.preparing;
    });
    try {
      await widget.runSync((stage) {
        if (!mounted) return;
        setState(() => _stage = stage);
      });
      if (!mounted) return;
      await widget.onSyncSuccess();
    } catch (e, st) {
      logAppError('auth.sync_before_logout', e, st);
      if (!mounted) return;
      setState(() {
        _busy = false;
        _failure = '$e';
      });
    }
  }

  String get _stageText {
    switch (_stage) {
      case ManualSyncStage.preparing:
        return AppStrings.cloudSyncSyncBeforeLogoutPreparing;
      case ManualSyncStage.pushing:
        return AppStrings.cloudSyncSyncBeforeLogoutPushing;
      case ManualSyncStage.pulling:
        return AppStrings.cloudSyncSyncBeforeLogoutPulling;
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return PopScope(
      canPop: !_busy,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(AppStrings.cloudSyncSyncBeforeLogoutTitle),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.s16),
            child: _failure == null
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(height: AppSpacing.s16),
                      Text(
                        _stageText,
                        textAlign: TextAlign.center,
                        style: textTheme.bodyLarge,
                      ),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        AppStrings.cloudSyncSyncBeforeLogoutFailureTitle,
                        style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: AppSpacing.s8),
                      Text(
                        _failure!,
                        style: textTheme.bodySmall?.copyWith(color: AppColors.onSurfaceVariant),
                      ),
                      const SizedBox(height: AppSpacing.s8),
                      Text(
                        AppStrings.cloudSyncLogoutWithoutSyncWarning,
                        style: textTheme.bodySmall?.copyWith(color: AppColors.onSurfaceVariant),
                      ),
                      const Spacer(),
                      FilledButton(
                        onPressed: _run,
                        child: const Text(AppStrings.cloudSyncRetry),
                      ),
                      const SizedBox(height: AppSpacing.s8),
                      FilledButton.tonal(
                        onPressed: _busy ? null : widget.onLogoutWithoutSync,
                        child: const Text(AppStrings.cloudSyncLogoutWithoutSync),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
