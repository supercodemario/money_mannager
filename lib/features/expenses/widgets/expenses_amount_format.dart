import 'package:flutter/widgets.dart';
import 'package:money_manager/share/share.dart';

/// Formats signed minor units with the active regional settings.
String formatExpenseMinor(BuildContext context, int minor) {
  return RegionalFormattingScope.of(context).formatMinor(minor);
}

/// Masks [minor] as `{currencySymbol} •••••` when Privacy mode is on and not revealed.
String privacyAwareExpenseAmount(
  BuildContext context,
  int minor, {
  required bool privacyEnabled,
  required bool temporarilyRevealed,
}) {
  if (privacyEnabled && !temporarilyRevealed) {
    return '${currentExpenseCurrencySymbol(context)} •••••';
  }
  return formatExpenseMinor(context, minor);
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
