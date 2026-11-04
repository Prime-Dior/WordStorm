import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Champ de pseudo limité à 12 caractères.
class NicknameField extends StatelessWidget {
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
  Widget build(BuildContext context) => TextField(
    controller: controller,
    maxLength: 12,
    textCapitalization: TextCapitalization.words,
    textInputAction: TextInputAction.go,
    onChanged: onChanged,
    onSubmitted: (_) => onSubmitted(),
    decoration: InputDecoration(
      labelText: 'Pseudo',
      hintText: hintText,
      errorText: errorText,
      counterText: '',
      filled: true,
      fillColor: const Color(0xFFCADDF3),
      labelStyle: const TextStyle(color: AppColors.navyBlue),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
    ),
    style: const TextStyle(color: AppColors.navyBlue),
  );
}
