import 'package:auto_route/auto_route.dart';
import 'package:money_manager/core/navigation/app_route_pop.dart';
import 'package:flutter/material.dart';
import 'package:money_manager/core/logging/app_log.dart';
import 'package:money_manager/share/share.dart';
import 'package:money_manager/sync/sync_orchestrator.dart';

typedef PostLoginCloudSyncRunner =
    Future<void> Function(void Function(ManualSyncStage stage) onStage);

/// Full-screen flow after sign-in when [totalRows] local-only expenses exist:
/// explicit sync, stage progress, completion, retry on failure.
@RoutePage()
class PostLoginCloudSyncScreen extends StatefulWidget {
  const PostLoginCloudSyncScreen({
    super.key,
    required this.totalRows,
    this.localRows,
    this.remoteRows,
    this.isBootstrapOnly = false,
    required this.runSync,
  });

  final int totalRows;
  final int? localRows;
  final int? remoteRows;
  final bool isBootstrapOnly;
  final PostLoginCloudSyncRunner runSync;

  @override
  State<PostLoginCloudSyncScreen> createState() =>
      _PostLoginCloudSyncScreenState();
}

class _PostLoginCloudSyncScreenState extends State<PostLoginCloudSyncScreen> {
  bool _running = false;
  bool _success = false;
  ManualSyncStage _stage = ManualSyncStage.preparing;
  String? _failure;

  String get _stageText {
    switch (_stage) {
      case ManualSyncStage.preparing:
        return AppStrings.cloudSyncPostAuthPreparing;
      case ManualSyncStage.pushing:
        return AppStrings.cloudSyncPostAuthPushing;
      case ManualSyncStage.pulling:
        return AppStrings.cloudSyncPostAuthPulling;
    }
  }

  bool get _looksAlreadySynced =>
      widget.localRows != null &&
      widget.remoteRows != null &&
      widget.totalRows == 0 &&
      widget.localRows == widget.remoteRows &&
      _failure == null;

  Future<void> _startSync() async {
    setState(() {
      _running = true;
      _success = false;
      _failure = null;
      _stage = ManualSyncStage.preparing;
    });
    try {
      await widget.runSync((stage) {
        if (!mounted) return;
        setState(() => _stage = stage);
      });
      if (!mounted) return;
      setState(() {
        _running = false;
        _success = true;
      });
    } catch (e, st) {
      logAppError('auth.post_login_sync', e, st);
      if (!mounted) return;
      setState(() {
        _running = false;
        _failure = '$e';
      });
    }
  }

  void _popDeferAllowCloseAuth() {
    context.popRoute(true);
  }

  void _popStayOnAuthAfterFailure() {
    context.popRoute(false);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return PopScope(
      canPop: !_running,
      child: Scaffold(
        appBar: AppBar(title: const Text(AppStrings.cloudSyncPostAuthTitle)),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.s16),
            child: _running
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
                : _success
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Spacer(),
                      const Icon(
                        Icons.check_circle_outline,
                        size: AppSpacing.s48,
                      ),
                      const SizedBox(height: AppSpacing.s12),
                      Text(
                        AppStrings.cloudSyncPostAuthSuccessTitle,
                        textAlign: TextAlign.center,
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.s8),
                      Text(
                        widget.isBootstrapOnly
                            ? AppStrings.cloudSyncPostAuthBootstrapSuccessBody
                            : AppStrings.cloudSyncPostAuthSuccessBody,
                        textAlign: TextAlign.center,
                        style: textTheme.bodyMedium?.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                      const Spacer(),
                      FilledButton(
                        onPressed: _popDeferAllowCloseAuth,
                        child: const Text(AppStrings.commonDone),
                      ),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        AppStrings.cloudSyncPostAuthPromptTitle,
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.s8),
                      Text(
                        widget.isBootstrapOnly
                            ? AppStrings.cloudSyncPostAuthBootstrapBody
                            : AppStrings.cloudSyncPostAuthPromptBody(
                                widget.totalRows,
                              ),
                        style: textTheme.bodyMedium?.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.s8),
                      if (widget.localRows != null)
                        Text(
                          AppStrings.cloudSyncPostAuthLocalRowsBody(
                            widget.localRows!,
                          ),
                          style: textTheme.bodySmall?.copyWith(
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      if (widget.localRows != null)
                        const SizedBox(height: AppSpacing.s4),
                      Text(
                        widget.remoteRows != null
                            ? AppStrings.cloudSyncPostAuthCloudRowsBody(
                                widget.remoteRows!,
                              )
                            : AppStrings.cloudSyncPostAuthCloudRowsUnavailable,
                        style: textTheme.bodySmall?.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                      if (widget.localRows != null &&
                          widget.remoteRows != null) ...[
                        const SizedBox(height: AppSpacing.s4),
                        Text(
                          AppStrings.cloudSyncPostAuthCompareRowsBody(
                            widget.localRows!,
                            widget.remoteRows!,
                          ),
                          style: textTheme.bodySmall?.copyWith(
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                      if (_looksAlreadySynced) ...[
                        const SizedBox(height: AppSpacing.s8),
                        Text(
                          AppStrings.cloudSyncPostAuthAlreadySyncedStatus,
                          style: textTheme.labelLarge?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                      if (_failure != null) ...[
                        const SizedBox(height: AppSpacing.s16),
                        Text(
                          AppStrings.cloudSyncPostAuthFailureTitle,
                          style: textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.s8),
                        Text(
                          _failure!,
                          style: textTheme.bodySmall?.copyWith(
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                      const Spacer(),
                      FilledButton(
                        onPressed: _looksAlreadySynced
                            ? _popDeferAllowCloseAuth
                            : _startSync,
                        child: Text(
                          _failure == null
                              ? (_looksAlreadySynced
                                    ? AppStrings
                                          .cloudSyncPostAuthAlreadySyncedAction
                                    : AppStrings.cloudSyncSyncNow)
                              : AppStrings.cloudSyncRetry,
                        ),
                      ),
                      if (!_looksAlreadySynced) ...[
                        const SizedBox(height: AppSpacing.s8),
                        FilledButton.tonal(
                          onPressed: _failure == null
                              ? _popDeferAllowCloseAuth
                              : _popStayOnAuthAfterFailure,
                          child: const Text(AppStrings.cloudSyncNotNow),
                        ),
                      ],
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
