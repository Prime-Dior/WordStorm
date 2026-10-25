import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

/// Champ de code de salon (maquette `.code` + `.jr`) :
/// affichage lisible copiable ou champ de saisie contraint à 6 caractères
/// alphanumériques sans ambigus, avec message d'erreur sous le champ.
class CodeField extends StatelessWidget {
  const CodeField({
    required this.controller,
    super.key,
    this.readOnly = false,
    this.onValidated,
    this.errorText,
    this.trailing,
  });

  final TextEditingController controller;
  final bool readOnly;
  final String? errorText;
  final Widget? trailing;

  /// Handler du bouton « OK » (champ de saisie uniquement).
  final VoidCallback? onValidated;

  static const String allowedAlphabet = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';

  @override
  Widget build(BuildContext context) {
    final hasError = errorText != null && errorText!.isNotEmpty;

    final field = Container(
      padding: const EdgeInsets.fromLTRB(10, 12, 10, 12),
      decoration: BoxDecoration(
        color: const Color(0xCC000000),
        borderRadius: BorderRadius.circular(16),
        border: hasError
            ? Border.all(color: AppColors.coral, width: 2)
            : Border.all(color: const Color(0x22FFFFFF), width: 2),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              readOnly: readOnly,
              maxLength: 6,
              enabled: !readOnly,
              inputFormatters: [
                // Majuscules uniquement, alphabet sans ambigus.
                TextInputFormatter.withFunction((old, next) {
                  final cleaned = next.text
                      .toUpperCase()
                      .split('')
                      .where(allowedAlphabet.contains)
                      .join();
                  return cleaned == next.text
                      ? next
                      : next.copyWith(text: cleaned);
                }),
              ],
              onChanged: (v) {
                final c = v
                    .toUpperCase()
                    .split('')
                    .where(allowedAlphabet.contains)
                    .join();
                final cursor = controller.value.selection.baseOffset.clamp(
                  0,
                  c.length,
                );
                controller.value = TextEditingValue(
                  text: c,
                  selection: TextSelection.collapsed(offset: cursor),
                );
              },
              style: const TextStyle(
                fontFamily: AppTheme.monoFont,
                fontWeight: FontWeight.w700,
                fontSize: 18,
                letterSpacing: 1.8,
                color: AppColors.navyBlue,
              ),
              decoration: InputDecoration(
                isDense: true,
                counterText: '',
                filled: true,
                fillColor: AppColors.offWhite,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: AppColors.blueGray,
                    width: 2,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: AppColors.blueGray,
                    width: 2,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.teal, width: 2),
                ),
                hintStyle: TextStyle(color: AppColors.navyBlue.withAlpha(0x77)),
                hintText: 'EX. 7F3K9A',
              ),
            ),
          ),
          ?trailing,
        ],
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        field,
        if (hasError)
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 4),
            child: Text(
              errorText!,
              style: const TextStyle(
                fontFamily: AppTheme.bodyFont,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFFFF8A8E),
              ),
            ),
          ),
      ],
    );
  }
}
