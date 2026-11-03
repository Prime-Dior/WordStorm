/// Champ de saisie du pseudo, partagé par la création de salon
/// (Nouvelle partie, multijoueur) et l'écran « Rejoindre un salon ».
library;

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

/// Champ du pseudo (1 à 12 caractères), dans le même style que [CodeField] (fond bleu clair,
/// bordure au survol et au focus, erreur sous le champ).
class NicknameField extends StatefulWidget {
  const NicknameField({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.onSubmitted,
    this.errorText,
    this.hintText = 'Champion',
  });

  final TextEditingController controller;
  final String? errorText;
  final String hintText;
  final ValueChanged<String> onChanged;
  final VoidCallback onSubmitted;

  @override
  State<NicknameField> createState() => _NicknameFieldState();
}

class _NicknameFieldState extends State<NicknameField> {
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

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        MouseRegion(
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
              maxLength: 12,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.go,
              onChanged: widget.onChanged,
              onSubmitted: (_) => widget.onSubmitted(),
              cursorColor: AppColors.navyBlue,
              style: const TextStyle(
                fontFamily: AppTheme.bodyFont,
                fontWeight: FontWeight.w600,
                fontSize: 15,
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
                hintText: widget.hintText,
                hintStyle: TextStyle(
                  fontFamily: AppTheme.bodyFont,
                  fontWeight: FontWeight.w600,
                  color: AppColors.navyBlue.withAlpha(0xAA),
                ),
              ),
            ),
          ),
        ),
        if (hasError)
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
