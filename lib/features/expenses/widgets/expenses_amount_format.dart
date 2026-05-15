import 'package:flutter/widgets.dart';
import 'package:money_manager/share/share.dart';

/// Formats signed minor units with the active regional settings.
String formatExpenseMinor(BuildContext context, int minor) {
  return RegionalFormattingScope.of(context).formatMinor(minor);
}

/// Formats signed minor units as numeric text without currency symbol.
String formatExpenseMinorNumericOnly(BuildContext context, int minor) {
  return RegionalFormattingScope.of(context).formatMinorNumericOnly(minor);
}

/// Returns current currency symbol from active regional settings.
String currentExpenseCurrencySymbol(BuildContext context) {
  return RegionalFormattingScope.of(context).currencySymbol;
}

/// Parses user-entered numeric money text into minor units using active separators.
int? parseExpenseMinorFromString(BuildContext context, String raw) {
  return RegionalFormattingScope.of(context).parseMinorFromString(raw);
}

/// Backward-compatible fallback for legacy call sites.
@Deprecated('Use formatExpenseMinor(context, minor)')
String formatExpenseUsdMinor(int minor) => RegionalFormattingData.defaults.formatMinor(minor);

/// Backward-compatible fallback for legacy call sites.
@Deprecated('Use parseExpenseMinorFromString(context, raw)')
int? parseUsdMinorFromString(String raw) => RegionalFormattingData.defaults.parseMinorFromString(raw);
