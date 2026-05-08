import 'package:flutter/widgets.dart';
import 'package:money_manager/share/regional/regional_formatting_data.dart';

/// Provides [RegionalFormattingData] for the subtree (typically below [MaterialApp.builder]).
class RegionalFormattingScope extends InheritedWidget {
  const RegionalFormattingScope({
    super.key,
    required this.data,
    required super.child,
  });

  final RegionalFormattingData data;

  static RegionalFormattingData of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<RegionalFormattingScope>();
    return scope?.data ?? RegionalFormattingData.defaults;
  }

  @override
  bool updateShouldNotify(RegionalFormattingScope oldWidget) => oldWidget.data != data;
}
