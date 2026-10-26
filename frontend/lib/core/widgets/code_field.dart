import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

/// Champ de saisie du code de salon (maquette : fond bleu clair, police
/// à chasse fixe, « EX. 7F3K9A »). Saisie contrainte à 6 caractères de
/// l'alphabet sans ambigus, en majuscules ; message d'erreur sous le champ.
class CodeField extends StatefulWidget {
  const CodeField({
    required this.controller,
    super.key,
    this.onValidated,
    this.errorText,
    this.trailing,
    this.autofocus = false,
  });

  final TextEditingController controller;
  final String? errorText;

  /// Élément à droite du champ (bouton « OK » du menu).
  final Widget? trailing;

  /// Appelé à la validation clavier (touche Entrée).
  final VoidCallback? onValidated;
  final bool autofocus;

  static const String allowedAlphabet = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';

  @override
  State<CodeField> createState() => _CodeFieldState();
}

class _CodeFieldState extends State<CodeField> {
  final FocusNode _focus = FocusNode();
  bool _hovered = false;

  @override
  void initState() {
    super.initState();
    _focus.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _focus
      ..removeListener(_onFocusChange)
      ..dispose();
    super.dispose();
  }

  // Majuscules uniquement, alphabet sans caractères ambigus.
  static final TextInputFormatter _formatter = TextInputFormatter.withFunction((
    oldValue,
    newValue,
  ) {
    final cleaned = newValue.text
        .toUpperCase()
        .split('')
        .where(CodeField.allowedAlphabet.contains)
        .join();
    if (cleaned == newValue.text) return newValue;
    return TextEditingValue(
      text: cleaned,
      selection: TextSelection.collapsed(offset: cleaned.length),
    );
  });

  @override
  Widget build(BuildContext context) {
    final error = widget.errorText;
    final hasError = error != null && error.isNotEmpty;
    final focused = _focus.hasFocus;
    final borderColor = hasError
        ? AppColors.coral
        : focused
        ? AppColors.teal
        : _hovered
        ? const Color(0xFF8FB3DF)
        : const Color(0x00FFFFFF);

    final field = MouseRegion(
      cursor: SystemMouseCursors.text,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        decoration: BoxDecoration(
          color: const Color(0xFFCADDF3),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: borderColor, width: 2),
          boxShadow: focused
              ? [
                  BoxShadow(
                    color: AppColors.teal.withAlpha(0x66),
                    blurRadius: 10,
                  ),
                ]
              : const [],
        ),
        child: TextField(
          controller: widget.controller,
          focusNode: _focus,
          autofocus: widget.autofocus,
          maxLength: 6,
          autocorrect: false,
          enableSuggestions: false,
          textCapitalization: TextCapitalization.characters,
          textInputAction: TextInputAction.go,
          inputFormatters: [_formatter],
          onSubmitted: (_) => widget.onValidated?.call(),
          cursorColor: AppColors.navyBlue,
          style: const TextStyle(
            fontFamily: AppTheme.monoFont,
            fontWeight: FontWeight.w700,
            fontSize: 16,
            letterSpacing: 1.5,
            color: AppColors.navyBlue,
          ),
          decoration: InputDecoration(
            isDense: true,
            counterText: '',
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
            hintText: 'EX. 7F3K9A',
            hintStyle: TextStyle(
              fontFamily: AppTheme.monoFont,
              fontWeight: FontWeight.w700,
              color: AppColors.navyBlue.withAlpha(0xAA),
            ),
          ),
        ),
      ),
    );

    final trailing = widget.trailing;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (trailing == null)
          field
        else
          Row(
            children: [
              Expanded(child: field),
              const SizedBox(width: 10),
              trailing,
            ],
          ),
        if (error != null && error.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 4),
            child: Text(
              error,
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
