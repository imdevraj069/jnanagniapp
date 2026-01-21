import 'package:flutter/material.dart';
import '../constants/colors.dart';

class CyberCard extends StatelessWidget {
  final Widget child;
  final Color borderColor;
  final EdgeInsetsGeometry? padding;

  const CyberCard({
    super.key,
    required this.child,
    this.borderColor = CyberColors.borderColor,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CyberColors.bgCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
        boxShadow: [
          if (borderColor != CyberColors.borderColor)
            BoxShadow(color: borderColor.withOpacity(0.3), blurRadius: 10, spreadRadius: 1)
        ],
      ),
      child: child,
    );
  }
}