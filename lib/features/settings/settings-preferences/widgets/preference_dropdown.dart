import 'package:flutter/material.dart';

class PreferenceDropdown extends StatelessWidget {
  const PreferenceDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
    this.optionLabel,
  });

  final String label;
  final String value;
  final List<String> options;
  final ValueChanged<String> onChanged;
  final String Function(String value)? optionLabel;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(label)),
        DropdownButton<String>(
          value: value,
          items: [
            for (final option in options)
              DropdownMenuItem<String>(
                value: option,
                child: Text(optionLabel?.call(option) ?? option.toUpperCase()),
              ),
          ],
          onChanged: (v) {
            if (v != null) onChanged(v);
          },
        ),
      ],
    );
  }
}
