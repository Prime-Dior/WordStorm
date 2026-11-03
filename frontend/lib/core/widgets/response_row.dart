import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'letter_tile.dart';

/// Nom d'une catégorie avec le champ où écrire sa réponse.
class ResponseRow extends StatelessWidget {
  const ResponseRow({
    required this.category,
    required this.onChanged,
    super.key,
    this.categoryColor,
    this.enabled = true,
    this.turnLocked = false,
    this.controller,
    this.textInputAction = TextInputAction.next,
    this.onSubmitted,
    this.iconName,
  });

  final ValueChanged<String> onChanged;
  final ValueChanged<String>? onSubmitted;
  final String category;
  final Color? categoryColor;
  final bool enabled;
  final bool turnLocked;
  final TextEditingController? controller;
  final TextInputAction textInputAction;
  final String? iconName;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            CategoryBadge(iconName: iconName ?? category, color: categoryColor),
            const SizedBox(width: 8),
            SizedBox(width: 90, child: Text(category)),
            Expanded(
              child: TextField(
                controller: controller,
                enabled: enabled && !turnLocked,
                textCapitalization: TextCapitalization.words,
                keyboardType: TextInputType.name,
                textInputAction: textInputAction,
                maxLength: 40,
                inputFormatters: [
                  FilteringTextInputFormatter.deny(
                    RegExp(r"[^\p{L}\s'\-]", unicode: true),
                  ),
                ],
                onChanged: onChanged,
                onSubmitted: onSubmitted,
                decoration: const InputDecoration(
                  hintText: 'Ta réponse',
                  counterText: '',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
