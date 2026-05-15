/// Validates RFC-4122 UUID strings (hex with hyphens).
bool isCanonicalUuidString(String input) {
  final s = input.trim();
  return RegExp(
    r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[1-5][0-9a-fA-F]{3}-[89abAB][0-9a-fA-F]{3}-[0-9a-fA-F]{12}$',
  ).hasMatch(s);
}

final RegExp _uuidInText = RegExp(
  r'[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[1-5][0-9a-fA-F]{3}-[89abAB][0-9a-fA-F]{3}-[0-9a-fA-F]{12}',
);

/// Returns a canonical UUID if [input] is one, or the first UUID substring found.
String? extractFirstCanonicalUuid(String? input) {
  if (input == null || input.isEmpty) return null;
  final t = input.trim();
  if (isCanonicalUuidString(t)) return t;
  final m = _uuidInText.firstMatch(t);
  return m?.group(0);
}
