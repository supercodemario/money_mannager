import 'package:connectivity_plus/connectivity_plus.dart';

/// OS-level connectivity signal for sync gating (not Supabase reachability).
abstract class ConnectivityReader {
  Future<bool> get isOnline;

  /// When null, the orchestrator does not subscribe to connectivity changes.
  Stream<List<ConnectivityResult>>? get onConnectivityChanged;
}

/// Treats [ConnectivityResult.none] as offline; any other result as online.
class ConnectivityGate implements ConnectivityReader {
  ConnectivityGate({
    Connectivity? connectivity,
    Future<List<ConnectivityResult>> Function()? checkConnectivity,
    Stream<List<ConnectivityResult>>? onConnectivityChanged,
  }) : _connectivity = connectivity ?? Connectivity(),
       _checkConnectivity = checkConnectivity,
       _onConnectivityChanged = onConnectivityChanged;

  final Connectivity _connectivity;
  final Future<List<ConnectivityResult>> Function()? _checkConnectivity;
  final Stream<List<ConnectivityResult>>? _onConnectivityChanged;

  static bool isOnlineResults(List<ConnectivityResult> results) {
    if (results.isEmpty) return false;
    return results.any((r) => r != ConnectivityResult.none);
  }

  @override
  Future<bool> get isOnline async {
    final results = _checkConnectivity != null
        ? await _checkConnectivity!()
        : await _connectivity.checkConnectivity();
    return isOnlineResults(results);
  }

  @override
  Stream<List<ConnectivityResult>>? get onConnectivityChanged =>
      _onConnectivityChanged ?? _connectivity.onConnectivityChanged;
}
