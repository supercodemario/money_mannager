/// Formats minor units (e.g. cents) as USD with a leading `$`.
String formatExpenseUsdMinor(int minor) {
  final sign = minor < 0 ? '-' : '';
  final v = minor.abs();
  final dollars = v ~/ 100;
  final cents = (v % 100).toString().padLeft(2, '0');
  return '$sign\$$dollars.$cents';
}

/// Parses user-entered currency text to minor units (e.g. `12.50` → 1250). Returns null if invalid.
int? parseUsdMinorFromString(String raw) {
  final t = raw.trim().replaceAll('\$', '').replaceAll(',', '');
  if (t.isEmpty) return null;
  final v = double.tryParse(t);
  if (v == null || v < 0) return null;
  return (v * 100).round();
}
