import 'package:flutter/material.dart';

import 'letter_tile.dart';

/// Ligne de catégorie avec une case à cocher.
class CheckRow extends StatelessWidget {
  const CheckRow({
    required this.label,
    super.key,
    this.iconName,
    this.iconColor,
    this.selected = false,
    this.locked = false,
    this.inactive = false,
    this.trailing,
    this.onToggle,
  });

  final String label;
  final String? iconName;
  final Color? iconColor;
  final bool selected;
  final bool locked;
  final bool inactive;
  final Widget? trailing;
  final VoidCallback? onToggle;

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      value: selected,
      onChanged: locked || inactive ? null : (_) => onToggle?.call(),
      title: Text(label),
      secondary: CategoryBadge(iconName: iconName ?? 'star', color: iconColor),
      controlAffinity: ListTileControlAffinity.trailing,
      subtitle: trailing,
    );
  }
}
