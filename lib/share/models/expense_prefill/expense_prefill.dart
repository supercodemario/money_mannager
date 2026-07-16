/// Prefill payload for the regular Add Expense screen (shared across features).
class ExpensePrefill {
  const ExpensePrefill({
    required this.amountMinor,
    this.note,
    this.date,
    this.sourceKey,
  });

  /// Amount in minor units (e.g. paise for INR).
  final int amountMinor;

  final String? note;
  final DateTime? date;

  /// Opaque local key (e.g. SMS id) returned on successful save for handled marking.
  final String? sourceKey;
}
