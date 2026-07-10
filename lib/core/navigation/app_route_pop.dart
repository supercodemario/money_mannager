import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

/// Pops the current page via auto_route when a [StackRouter] is in scope;
/// otherwise falls back to [Navigator] (e.g. isolated widget tests).
extension AppRoutePop on BuildContext {
  Future<bool> popRoute<T extends Object?>([T? result]) {
    final scope = StackRouterScope.of(this);
    if (scope != null) {
      return scope.controller.maybePop<T>(result);
    }
    return Navigator.of(this).maybePop<T>(result);
  }
}
