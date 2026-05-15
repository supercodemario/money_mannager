import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart';
import 'package:money_manager/data/local/app_database.dart';

/// Resolved regional settings used for locale and money formatting app-wide.
@immutable
class RegionalFormattingData {
  const RegionalFormattingData({
    required this.currencyCode,
    required this.languageCode,
    required this.numberFormatPreset,
  });

  final String currencyCode;
  final String languageCode;

  /// Persisted preset: `us`, `eu`, or `in`.
  final String numberFormatPreset;

  static const RegionalFormattingData defaults = RegionalFormattingData(
    currencyCode: 'USD',
    languageCode: 'en',
    numberFormatPreset: 'us',
  );

  static const List<Locale> supportedLocales = [
    Locale('en'),
    Locale('es'),
    Locale('fr'),
  ];

  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = [
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ];

  factory RegionalFormattingData.fromPreference(UserPreference? p) {
    if (p == null) return defaults;
    return RegionalFormattingData(
      currencyCode: p.currencyCode,
      languageCode: p.languageCode,
      numberFormatPreset: p.numberFormat,
    );
  }

  Locale get materialLocale => Locale(languageCode);

  /// Grouping / separators for currency amounts (can differ from [materialLocale]).
  String get currencyFormattingLocale {
    switch (numberFormatPreset) {
      case 'eu':
        return 'de_DE';
      case 'in':
        return 'en_IN';
      case 'us':
      default:
        return 'en_US';
    }
  }

  String get decimalSeparator {
    switch (numberFormatPreset) {
      case 'eu':
        return ',';
      case 'us':
      case 'in':
      default:
        return '.';
    }
  }

  NumberFormat _currencyFormat() => NumberFormat.simpleCurrency(
        locale: currencyFormattingLocale,
        name: currencyCode,
      );

  /// Symbol or short currency glyph for inline labels (e.g. next to amount fields).
  String get currencySymbol {
    final symbol = _currencyFormat().currencySymbol;
    return symbol.isEmpty ? currencyCode : symbol;
  }

  /// Full formatted currency string from signed minor units (e.g. cents).
  String formatMinor(int minor) => _currencyFormat().format(minor / 100.0);

  /// Major-unit numeric text without currency symbol (for editable fields mirroring prior USD UX).
  String formatMinorNumericOnly(int minor) {
    final sign = minor < 0 ? '-' : '';
    final v = minor.abs();
    final whole = v ~/ 100;
    final frac = (v % 100).toString().padLeft(2, '0');
    return '$sign$whole$decimalSeparator$frac';
  }

  /// Parses user-entered currency text to minor units.
  int? parseMinorFromString(String raw) {
    var t = raw.trim();
    if (t.isEmpty) return null;

    t = t.replaceAll(RegExp(r'[^\d.,\-+\s\u00A3\u20AC\u00A5\u20B9\u0024]'), '');
    t = t.replaceAll(RegExp(r'\s'), '');

    String normalized;
    switch (numberFormatPreset) {
      case 'eu':
        normalized = t.replaceAll('.', '').replaceAll(',', '.');
        break;
      case 'in':
      case 'us':
      default:
        normalized = t.replaceAll(',', '');
        break;
    }

    final v = double.tryParse(normalized);
    if (v == null || v < 0) return null;
    return (v * 100).round();
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RegionalFormattingData &&
          currencyCode == other.currencyCode &&
          languageCode == other.languageCode &&
          numberFormatPreset == other.numberFormatPreset;

  @override
  int get hashCode => Object.hash(currencyCode, languageCode, numberFormatPreset);
}
