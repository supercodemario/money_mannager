import 'package:flutter/material.dart';
import 'package:money_manager/share/tokens/tokens.dart';

class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.color,
    this.borderRadius,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final double? borderRadius;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color ?? AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(borderRadius ?? AppRadius.xl),
      ),
      child: Padding(
        padding: padding ?? const EdgeInsets.all(AppSpacing.s16),
        child: child,
      ),
    );
  }
}

