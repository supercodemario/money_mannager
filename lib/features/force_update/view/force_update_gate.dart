import 'dart:io';

import 'package:flutter/material.dart';
import 'package:money_manager/data/remote/supabase_env.dart';
import 'package:money_manager/features/force_update/data/app_build_info.dart';
import 'package:money_manager/features/force_update/data/force_update_policy_cache.dart';
import 'package:money_manager/features/force_update/data/force_update_remote.dart';
import 'package:money_manager/features/force_update/data/force_update_resolver.dart';
import 'package:money_manager/features/force_update/models/force_update_policy/force_update_policy.dart';
import 'package:money_manager/features/force_update/view/force_update_screen.dart';
import 'package:money_manager/share/share.dart';

/// Android-only root gate: replaces [child] when installed build is below policy min.
///
/// Must sit under [MaterialApp] (e.g. `MaterialApp.builder`) so theme/strings work.
class ForceUpdateGate extends StatefulWidget {
  const ForceUpdateGate({
    super.key,
    required this.child,
    this.resolver = const ForceUpdateResolver(),
    this.remote,
    this.cache,
    this.buildInfo = const AppBuildInfo(),
  });

  final Widget child;
  final ForceUpdateResolver resolver;
  final ForceUpdateRemote? remote;
  final ForceUpdatePolicyCache? cache;
  final AppBuildInfo buildInfo;

  @override
  State<ForceUpdateGate> createState() => _ForceUpdateGateState();
}

class _ForceUpdateGateState extends State<ForceUpdateGate>
    with WidgetsBindingObserver {
  bool _checking = true;
  ForceUpdatePolicy? _forcedPolicy;

  late final ForceUpdateRemote _remote = widget.remote ?? ForceUpdateRemote();
  late final ForceUpdatePolicyCache _cache =
      widget.cache ?? ForceUpdatePolicyCache();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _runCheck());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _runCheck();
    }
  }

  Future<void> _runCheck() async {
    if (!Platform.isAndroid) {
      if (!mounted) return;
      setState(() {
        _checking = false;
        _forcedPolicy = null;
      });
      return;
    }

    if (!SupabaseEnv.isConfigured && await _cache.read() == null) {
      if (!mounted) return;
      setState(() {
        _checking = false;
        _forcedPolicy = null;
      });
      return;
    }

    final decision = await widget.resolver.resolve(
      fetchRemote: _remote.fetchAndroidPolicy,
      readCache: _cache.read,
      writeCache: _cache.write,
      readLocalBuild: widget.buildInfo.readBuildNumber,
    );

    if (!mounted) return;
    setState(() {
      _checking = false;
      _forcedPolicy = decision.mustUpdate ? decision.policy : null;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!Platform.isAndroid) return widget.child;

    final policy = _forcedPolicy;
    if (policy != null) {
      return ForceUpdateScreen(policy: policy);
    }

    if (_checking) {
      return Stack(
        fit: StackFit.expand,
        children: [
          widget.child,
          ModalBarrier(
            dismissible: false,
            color: AppColors.onSurface.withValues(alpha: 0.4),
          ),
          const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          ),
        ],
      );
    }

    return widget.child;
  }
}
