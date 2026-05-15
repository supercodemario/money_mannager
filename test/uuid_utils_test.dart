import 'package:flutter_test/flutter_test.dart';
import 'package:money_manager/share/share.dart';

void main() {
  test('isCanonicalUuidString accepts RFC4122 samples', () {
    expect(isCanonicalUuidString('550e8400-e29b-41d4-a716-446655440000'), isTrue);
    expect(isCanonicalUuidString(' 550e8400-e29b-41d4-a716-446655440000 '), isTrue);
  });

  test('isCanonicalUuidString rejects garbage', () {
    expect(isCanonicalUuidString('not-a-uuid'), isFalse);
    expect(isCanonicalUuidString(''), isFalse);
  });

  test('extractFirstCanonicalUuid accepts plain UUID and embedded text', () {
    const id = '550e8400-e29b-41d4-a716-446655440000';
    expect(extractFirstCanonicalUuid(id), id);
    expect(extractFirstCanonicalUuid(' prefix $id suffix '), id);
    expect(extractFirstCanonicalUuid('no uuid here'), isNull);
  });
}
