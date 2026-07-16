import 'package:money_manager/features/sms_payments/models/parsed_payment_sms/parsed_payment_sms.dart';

/// Heuristic parser for India bank / UPI debit payment SMS.
class IndiaPaymentSmsParser {
  IndiaPaymentSmsParser._();

  static final _otp = RegExp(
    r'\b(otp|one[\s-]?time\s+password|verification\s+code)\b',
    caseSensitive: false,
  );
  static final _balanceNoise = RegExp(
    r'(available\s+balance|avl\.?\s*bal|a/c\s+balance|account\s+balance)',
    caseSensitive: false,
  );
  static final _creditOnly = RegExp(
    r'\b(credited|received|credit(ed)?\s+to|deposit(ed)?)\b',
    caseSensitive: false,
  );
  static final _debitHint = RegExp(
    r'\b(debited|debit|spent|paid|purchase|txn|transaction|withdrawn|sent\s+to|upi)\b',
    caseSensitive: false,
  );
  static final _amountPrefixed = RegExp(
    r'(?:₹|rs\.?\s*|inr\s*)\s*([\d,]+(?:\.\d{1,2})?)',
    caseSensitive: false,
  );
  static final _amountSuffixed = RegExp(
    r'([\d,]+(?:\.\d{1,2})?)\s*(?:₹|rs\.?|inr)\b',
    caseSensitive: false,
  );
  static final _merchantTo = RegExp(
    r'(?:paid\s+to|sent\s+to|to|at|towards)\s+([A-Za-z0-9 &._-]{2,40})',
    caseSensitive: false,
  );

  /// Returns a candidate or null if the message should be excluded.
  static ParsedPaymentSms? tryParse({
    required String key,
    required String body,
    String? address,
    DateTime? date,
  }) {
    final trimmed = body.trim();
    if (trimmed.isEmpty) return null;

    if (_otp.hasMatch(trimmed)) return null;
    if (_balanceNoise.hasMatch(trimmed) && !_debitHint.hasMatch(trimmed)) {
      return null;
    }

    final isCredit = _creditOnly.hasMatch(trimmed);
    final isDebit = _debitHint.hasMatch(trimmed);
    if (isCredit && !isDebit) return null;
    if (!isDebit && !_amountPrefixed.hasMatch(trimmed) && !_amountSuffixed.hasMatch(trimmed)) {
      return null;
    }
    // Require a debit-ish signal OR explicit currency amount with payment verbs.
    if (!isDebit) return null;

    final amountMinor = _parseAmountMinor(trimmed);
    if (amountMinor == null || amountMinor <= 0) return null;

    final note = _buildNote(trimmed, address);
    return ParsedPaymentSms(
      key: key,
      amountMinor: amountMinor,
      note: note,
      occurredAt: date,
      address: address,
    );
  }

  static int? _parseAmountMinor(String body) {
    final match = _amountPrefixed.firstMatch(body) ?? _amountSuffixed.firstMatch(body);
    if (match == null) return null;
    final raw = match.group(1);
    if (raw == null) return null;
    final normalized = raw.replaceAll(',', '');
    final value = double.tryParse(normalized);
    if (value == null || value <= 0) return null;
    return (value * 100).round();
  }

  static String _buildNote(String body, String? address) {
    final merchant = _merchantTo.firstMatch(body)?.group(1)?.trim();
    if (merchant != null && merchant.isNotEmpty) {
      final cleaned = merchant.replaceAll(RegExp(r'\s+'), ' ');
      if (cleaned.length <= 48) return cleaned;
      return '${cleaned.substring(0, 45)}...';
    }
    if (address != null && address.trim().isNotEmpty) {
      final compact = body.replaceAll(RegExp(r'\s+'), ' ').trim();
      final snippet = compact.length > 40 ? '${compact.substring(0, 37)}...' : compact;
      return '${address.trim()} · $snippet';
    }
    final compact = body.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (compact.length <= 60) return compact;
    return '${compact.substring(0, 57)}...';
  }
}
