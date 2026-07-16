import 'dart:io';

import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';
import 'package:money_manager/features/sms_payments/data/india_payment_sms_parser.dart';
import 'package:money_manager/features/sms_payments/models/parsed_payment_sms/parsed_payment_sms.dart';

/// Raw inbox row before parsing.
class RawInboxSms {
  const RawInboxSms({
    required this.key,
    required this.body,
    this.address,
    this.date,
  });

  final String key;
  final String body;
  final String? address;
  final DateTime? date;
}

/// Android-only inbox reader. No-ops on other platforms.
class SmsInboxReader {
  SmsInboxReader({SmsQuery? query}) : _query = query ?? SmsQuery();

  final SmsQuery _query;

  static const lookbackDays = 14;
  static const queryCount = 200;

  Future<List<RawInboxSms>> readRecent() async {
    if (!Platform.isAndroid) return const [];

    final messages = await _query.querySms(
      kinds: [SmsQueryKind.inbox],
      count: queryCount,
      sort: true,
    );

    final cutoff = DateTime.now().subtract(const Duration(days: lookbackDays));
    final out = <RawInboxSms>[];
    for (final m in messages) {
      final date = m.date ?? m.dateSent;
      if (date != null && date.isBefore(cutoff)) continue;
      final body = m.body;
      if (body == null || body.trim().isEmpty) continue;
      final key = _stableKey(m);
      out.add(
        RawInboxSms(
          key: key,
          body: body,
          address: m.address,
          date: date,
        ),
      );
    }
    return out;
  }

  String _stableKey(SmsMessage m) {
    if (m.id != null) return 'sms_${m.id}';
    final addr = m.address ?? '';
    final ms = (m.date ?? m.dateSent)?.millisecondsSinceEpoch ?? 0;
    final body = m.body ?? '';
    final fingerprint = Object.hash(addr, ms, body.length, body.hashCode);
    return 'sms_h_$fingerprint';
  }
}

/// Parses raw inbox rows into payment candidates.
List<ParsedPaymentSms> parsePaymentCandidates(List<RawInboxSms> raw) {
  final out = <ParsedPaymentSms>[];
  for (final r in raw) {
    final parsed = IndiaPaymentSmsParser.tryParse(
      key: r.key,
      body: r.body,
      address: r.address,
      date: r.date,
    );
    if (parsed != null) out.add(parsed);
  }
  return out;
}
