import 'package:flutter/material.dart';
import 'package:money_manager/share/share.dart';

class QuickAddKeypad extends StatelessWidget {
  const QuickAddKeypad({
    super.key,
    required this.onDigit,
    required this.onDot,
    required this.onBackspace,
  });

  final ValueChanged<String> onDigit;
  final VoidCallback onDot;
  final VoidCallback onBackspace;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: AppSpacing.s8,
      crossAxisSpacing: AppSpacing.s8,
      childAspectRatio: 2.4,
      children: [
        for (final d in const ['1', '2', '3', '4', '5', '6', '7', '8', '9'])
          _KeyButton(
            label: d,
            onTap: () => onDigit(d),
          ),
        _KeyButton(label: '.', onTap: onDot),
        _KeyButton(label: '0', onTap: () => onDigit('0')),
        _KeyButton(
          icon: Icons.backspace,
          onTap: onBackspace,
          fill: AppColors.surfaceContainerHigh,
        ),
      ],
    );
  }
}

class _KeyButton extends StatelessWidget {
  const _KeyButton({this.label, this.icon, required this.onTap, this.fill});

  final String? label;
  final IconData? icon;
  final VoidCallback onTap;
  final Color? fill;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return AppCard(
      padding: EdgeInsets.zero,
      color: fill ?? AppColors.surfaceContainerLowest,
      borderRadius: AppRadius.xl,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          child: Center(
            child: icon != null
                ? Icon(icon, color: AppColors.onSurfaceVariant, size: AppSpacing.s20)
                : Text(
                    label ?? '',
                    style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                  ),
          ),
        ),
      ),
    );
  }
}

