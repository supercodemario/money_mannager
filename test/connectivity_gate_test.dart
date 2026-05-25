import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money_manager/sync/connectivity_gate.dart';

void main() {
  group('ConnectivityGate.isOnlineResults', () {
    test('none only is offline', () {
      expect(
        ConnectivityGate.isOnlineResults([ConnectivityResult.none]),
        isFalse,
      );
    });

    test('empty list is offline', () {
      expect(ConnectivityGate.isOnlineResults([]), isFalse);
    });

    test('wifi is online', () {
      expect(
        ConnectivityGate.isOnlineResults([ConnectivityResult.wifi]),
        isTrue,
      );
    });

    test('none with wifi is online', () {
      expect(
        ConnectivityGate.isOnlineResults([
          ConnectivityResult.none,
          ConnectivityResult.wifi,
        ]),
        isTrue,
      );
    });
  });

  group('ConnectivityGate.isOnline', () {
    test('uses injected checkConnectivity', () async {
      final gate = ConnectivityGate(
        checkConnectivity: () async => [ConnectivityResult.wifi],
      );
      expect(await gate.isOnline, isTrue);
    });

    test('reports offline when check returns none', () async {
      final gate = ConnectivityGate(
        checkConnectivity: () async => [ConnectivityResult.none],
      );
      expect(await gate.isOnline, isFalse);
    });
  });
}
