/// A parsed India payment/debit SMS candidate for the Home list.
class ParsedPaymentSms {
  const ParsedPaymentSms({
    required this.key,
    required this.amountMinor,
    required this.note,
    this.occurredAt,
    this.address,
  });

  /// Stable local id (Android SMS id or fingerprint).
  final String key;
  final int amountMinor;
  final String note;
  final DateTime? occurredAt;
  final String? address;
}
