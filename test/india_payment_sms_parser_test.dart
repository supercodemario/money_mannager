import 'package:flutter_test/flutter_test.dart';
import 'package:money_manager/features/sms_payments/data/india_payment_sms_parser.dart';

void main() {
  group('IndiaPaymentSmsParser', () {
    test('parses UPI debit with Rs amount', () {
      const body =
          'Rs.1,250.00 debited from A/c XX1234 on 14-07-26 and paid to Swiggy via UPI';
      final parsed = IndiaPaymentSmsParser.tryParse(
        key: '1',
        body: body,
        address: 'VK-HDFCBK',
        date: DateTime(2026, 7, 14),
      );
      expect(parsed, isNotNull);
      expect(parsed!.amountMinor, 125000);
      expect(parsed.note.toLowerCase(), contains('swiggy'));
    });

    test('parses INR spent on card', () {
      const body = 'INR 499.00 spent on your HDFC Card XX4321 at AMAZON';
      final parsed = IndiaPaymentSmsParser.tryParse(key: '2', body: body);
      expect(parsed, isNotNull);
      expect(parsed!.amountMinor, 49900);
    });

    test('parses rupee symbol paid via PhonePe', () {
      const body = 'You paid ₹80 to Zomato via PhonePe';
      final parsed = IndiaPaymentSmsParser.tryParse(key: '3', body: body);
      expect(parsed, isNotNull);
      expect(parsed!.amountMinor, 8000);
    });

    test('excludes OTP messages', () {
      const body = 'Your OTP is 123456 for UPI payment of Rs.500';
      final parsed = IndiaPaymentSmsParser.tryParse(key: '4', body: body);
      expect(parsed, isNull);
    });

    test('excludes credit-only messages', () {
      const body = 'Rs.2,000.00 credited to A/c XX1234. Available balance Rs.10,000';
      final parsed = IndiaPaymentSmsParser.tryParse(key: '5', body: body);
      expect(parsed, isNull);
    });

    test('excludes balance-only alerts', () {
      const body = 'Your available balance is Rs.5,432.10';
      final parsed = IndiaPaymentSmsParser.tryParse(key: '6', body: body);
      expect(parsed, isNull);
    });
  });
}
