import 'package:flutter_test/flutter_test.dart';
import 'package:money_manager/features/force_update/data/force_update_resolver.dart';
import 'package:money_manager/features/force_update/models/force_update_decision/force_update_decision.dart';
import 'package:money_manager/features/force_update/models/force_update_policy/force_update_policy.dart';

void main() {
  const resolver = ForceUpdateResolver();
  const policy = ForceUpdatePolicy(
    minBuild: 10,
    storeUrl: 'https://play.google.com/store/apps/details?id=com.nexkind.homelybudget',
    message: 'Please update',
  );

  group('ForceUpdateResolver.decide', () {
    test('forces when local build is below min', () {
      final d = resolver.decide(localBuild: 9, policy: policy);
      expect(d.mustUpdate, isTrue);
      expect(d.policy?.minBuild, 10);
    });

    test('allows when local build equals min', () {
      final d = resolver.decide(localBuild: 10, policy: policy);
      expect(d.outcome, ForceUpdateOutcome.allow);
    });

    test('allows when local build is above min', () {
      final d = resolver.decide(localBuild: 11, policy: policy);
      expect(d.mustUpdate, isFalse);
    });

    test('allows when policy is null', () {
      final d = resolver.decide(localBuild: 1, policy: null);
      expect(d.mustUpdate, isFalse);
    });
  });

  group('ForceUpdateResolver.resolve', () {
    test('uses remote policy and writes cache', () async {
      ForceUpdatePolicy? cached;
      final d = await resolver.resolve(
        fetchRemote: () async => policy,
        readCache: () async => cached,
        writeCache: (p) async => cached = p,
        readLocalBuild: () async => 5,
      );
      expect(d.mustUpdate, isTrue);
      expect(cached?.minBuild, 10);
    });

    test('uses cache when fetch fails', () async {
      final d = await resolver.resolve(
        fetchRemote: () async => null,
        readCache: () async => policy,
        writeCache: (_) async {},
        readLocalBuild: () async => 5,
      );
      expect(d.mustUpdate, isTrue);
    });

    test('allows when fetch fails and no cache', () async {
      final d = await resolver.resolve(
        fetchRemote: () async => null,
        readCache: () async => null,
        writeCache: (_) async {},
        readLocalBuild: () async => 5,
      );
      expect(d.mustUpdate, isFalse);
    });

    test('allows when remote says current enough', () async {
      final d = await resolver.resolve(
        fetchRemote: () async => policy,
        readCache: () async => null,
        writeCache: (_) async {},
        readLocalBuild: () async => 10,
      );
      expect(d.mustUpdate, isFalse);
    });
  });
}
