import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/salon_code.dart';
import '../../core/widgets/arcade_button.dart';
import '../../core/widgets/code_field.dart';
import '../../core/widgets/screen_scaffold.dart';
import '../../core/widgets/wordstorm_logo.dart';

/// Écran « Rejoindre un salon » (Figma, ajout prévu) : code 6 signes
/// sans ambigus + pseudo. Validation de la **forme** locale ici ; la
/// recherche réelle du salon (et l'écran « Salon introuvable ») passe
/// par le scrutin Firestore à la phase 7 — rien n'est simulé.
class JoinScreen extends StatefulWidget {
  const JoinScreen({super.key});

  @override
  State<JoinScreen> createState() => _JoinScreenState();
}

class _JoinScreenState extends State<JoinScreen> {
  final _code = TextEditingController();
  final _nickname = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _code.dispose();
    _nickname.dispose();
    super.dispose();
  }

  void _submit() {
    final code = _code.text.trim().toUpperCase();
    if (!SalonCode.isWellFormed(code)) {
      setState(() {
        _error = 'Code : 6 lettres/chiffres (sans 0, O, 1, I).';
      });
      return;
    }
    setState(() => _error = null);
    context.push('/lobby?code=$code');
  }

  @override
  Widget build(BuildContext context) {
    return ScreenScaffold(
      skylineHeight: 280,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const WordstormLogoSmall(),
            const SizedBox(height: 30),
            const Text(
              'REJOINDRE UN SALON',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: AppTheme.displayFont,
                fontSize: 30,
                color: AppColors.offWhite,
              ),
            ),
            const SizedBox(height: 20),
            const _Label('CODE DU SALON'),
            CodeField(
              controller: _code,
              errorText: _error,
              onValidated: _submit,
              trailing: Padding(
                padding: const EdgeInsets.only(left: 8),
                child: ArcadeButton(
                  label: 'OK',
                  small: true,
                  onPressed: _submit,
                ),
              ),
            ),
            const SizedBox(height: 14),
            const _Label('TON PSEUDO'),
            TextField(
              controller: _nickname,
              maxLength: 12,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                isDense: true,
                counterText: '',
                filled: true,
                fillColor: AppColors.offWhite,
                hintText: 'Champion',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              style: const TextStyle(
                fontFamily: AppTheme.bodyFont,
                fontWeight: FontWeight.w600,
                color: AppColors.navyBlue,
              ),
            ),
            const SizedBox(height: 22),
            ArcadeButton(
              label: 'Rejoindre',
              variant: ArcadeButtonVariant.teal,
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 6, left: 4),
    child: Text(
      text,
      style: const TextStyle(
        fontFamily: AppTheme.bodyFont,
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: .8,
        color: AppColors.blueGray,
      ),
    ),
  );
}
