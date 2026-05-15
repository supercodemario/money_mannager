import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:money_manager/app/app_services.dart';
import 'package:money_manager/sync/sync_orchestrator.dart';

/// Starts [SyncOrchestrator] once [AppServices] is available; disposes on unmount.
class SyncLifecycle extends StatefulWidget {
  const SyncLifecycle({super.key, required this.child});

  final Widget child;

  @override
  State<SyncLifecycle> createState() => _SyncLifecycleState();
}

class _SyncLifecycleState extends State<SyncLifecycle> {
  SyncOrchestrator? _orchestrator;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_orchestrator != null) return;
    final s = AppServices.of(context);
    final o = SyncOrchestrator(
      db: s.db,
      cloud: s.cloudSync,
      expenses: s.expenses,
      expenseLimits: s.expenseLimits,
      recurring: s.recurring,
    );
    o.start();
    _orchestrator = o;
    if (s.cloudSync.syncAllowed) {
      unawaited(s.profiles.hydrateDisplayNameFromAuthSession());
    }
  }

  @override
  void dispose() {
    _orchestrator?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
