import 'package:money_manager/features/sms_payments/models/parsed_payment_sms/parsed_payment_sms.dart';

enum PaymentSmsPermissionPhase {
  /// Not yet shown explain dialog.
  needsExplain,

  /// User dismissed explain; show enable CTA.
  dismissed,

  /// System permission not granted (after request or permanently).
  denied,

  /// Granted — list can load.
  granted,
}

class PaymentSmsState {
  const PaymentSmsState({
    this.phase = PaymentSmsPermissionPhase.needsExplain,
    this.items = const [],
    this.loading = false,
    this.errorText,
  });

  final PaymentSmsPermissionPhase phase;
  final List<ParsedPaymentSms> items;
  final bool loading;
  final String? errorText;

  PaymentSmsState copyWith({
    PaymentSmsPermissionPhase? phase,
    List<ParsedPaymentSms>? items,
    bool? loading,
    String? errorText,
    bool clearError = false,
  }) {
    return PaymentSmsState(
      phase: phase ?? this.phase,
      items: items ?? this.items,
      loading: loading ?? this.loading,
      errorText: clearError ? null : (errorText ?? this.errorText),
    );
  }
}
