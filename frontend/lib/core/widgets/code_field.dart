import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Champ simple pour saisir ou afficher le code d'un salon.
class CodeField extends StatelessWidget {
  const CodeField({
    required this.controller,
    super.key,
    this.readOnly = false,
    this.onValidated,
    this.onChanged,
    this.errorText,
    this.trailing,
  });

  final TextEditingController controller;
  final bool readOnly;
  final VoidCallback? onValidated;
  final ValueChanged<String>? onChanged;
  final String? errorText;
  final Widget? trailing;

  static const String allowedAlphabet = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';

  @override
  Widget build(BuildContext context) {
    final hasError = errorText != null && errorText!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                readOnly: readOnly,
                enabled: !readOnly,
                maxLength: 6,
                inputFormatters: [
                  TextInputFormatter.withFunction((oldValue, newValue) {
                    final text = newValue.text
                        .toUpperCase()
                        .split('')
                        .where(allowedAlphabet.contains)
                        .join();
                    return newValue.copyWith(text: text);
                  }),
                ],
                onChanged: onChanged,
                onSubmitted: (_) => onValidated?.call(),
                decoration: InputDecoration(
                  labelText: 'Code du salon',
                  counterText: '',
                  errorText: hasError ? errorText : null,
                  border: const OutlineInputBorder(),
                ),
              ),
            ),
            if (trailing != null) ...[const SizedBox(width: 8), trailing!],
          ],
        ),
      ],
    );
  }
}
