import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Bouton simple réutilisé dans les pages.
enum ArcadeButtonVariant { yellow, teal, purple, dark, green, red }

class ArcadeButton extends StatelessWidget {
  const ArcadeButton({
    required this.label,
    super.key,
    this.onPressed,
    this.variant = ArcadeButtonVariant.yellow,
    this.small = false,
    this.fontSize = 18,
    this.textColor,
    this.padding,
    this.borderRadius,
    this.flex = 1,
    this.minHeight,
  });

  final String label;
  final VoidCallback? onPressed;
  final ArcadeButtonVariant variant;
  final bool small;
  final double fontSize;
  final Color? textColor;
  final EdgeInsetsGeometry? padding;
  final double? borderRadius;
  final int flex;
  final double? minHeight;

  Color get _color {
    switch (variant) {
      case ArcadeButtonVariant.yellow:
        return const Color(0xFFFFB703);
      case ArcadeButtonVariant.teal:
        return AppColors.validate;
      case ArcadeButtonVariant.purple:
        return const Color(0xFF7B61FF);
      case ArcadeButtonVariant.green:
        return const Color(0xFF1FBF74);
      case ArcadeButtonVariant.red:
        return const Color(0xFFFF5A5F);
      case ArcadeButtonVariant.dark:
        return const Color(0xFF344563);
    }
  }

  @override
  Widget build(BuildContext context) {
    final button = ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: _color,
        foregroundColor: textColor ?? Colors.white,
        padding: padding ?? const EdgeInsets.all(12),
        minimumSize: Size(0, minHeight ?? (small ? 44 : 54)),
        elevation: onPressed == null ? 0 : 3,
        shadowColor: Colors.black.withValues(alpha: 0.25),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius ?? 12),
        ),
      ),
      child: Text(
        label.toUpperCase(),
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: small ? 14 : fontSize,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.4,
        ),
      ),
    );

    if (flex > 1) return Expanded(flex: flex, child: button);
    return button;
  }
}
