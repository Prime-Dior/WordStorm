import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/salon_code.dart';
import '../../core/widgets/arcade_button.dart';
import '../../core/widgets/code_field.dart';
import '../../core/widgets/screen_scaffold.dart';
import '../../core/widgets/ui_kit.dart';
import '../multiplayer/demo_room.dart';

/// Ouvre le salon correspondant à un code bien formé.
///
/// Sans backend, seul le salon de démonstration ([DemoRoom.joinableCode])
/// existe : il ouvre la vue invité du salon (maquette 09). Tout autre
/// code affiche « Salon introuvable » (maquette 17). À la phase 7, la
/// recherche se fera dans Firestore.
void openSalonByCode(BuildContext context, String code) {
  if (code == DemoRoom.joinableCode) {
    context.push('/lobby?role=guest&code=$code');
  } else {
    context.push('/not-found');
  }
}

/// Écran « Rejoindre un salon » (maquette 22) : saisie du code
/// d'invitation, bouton REJOINDRE et retour au menu.
class JoinScreen extends StatefulWidget {
  const JoinScreen({super.key, this.initialCode});

  /// Code déjà saisi dans le menu (facultatif).
  final String? initialCode;

  @override
  State<JoinScreen> createState() => _JoinScreenState();
}

class _JoinScreenState extends State<JoinScreen> {
  late final TextEditingController _code = TextEditingController(
    text: widget.initialCode ?? '',
  );
  String? _error;

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  void _submit() {
    final code = SalonCode.normalized(_code.text);
    if (!SalonCode.isWellFormed(code)) {
      setState(() {
        _error = 'Le code fait 6 lettres ou chiffres (sans 0, O, 1, I).';
      });
      return;
    }
    setState(() => _error = null);
    openSalonByCode(context, code);
  }

  @override
  Widget build(BuildContext context) {
    return ScreenScaffold(
      skylineHeight: 280,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 22),
            ScreenTitle('Rejoindre un salon', onBack: () => context.pop()),
            const SizedBox(height: 40),
            DarkPanel(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Code d’invitation',
                    style: TextStyle(
                      fontFamily: AppTheme.bodyFont,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.offWhite,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Saisis le code du salon pour le rejoindre.',
                    style: TextStyle(
                      fontFamily: AppTheme.bodyFont,
                      fontSize: 12,
                      color: AppColors.blueGray,
                    ),
                  ),
                  const SizedBox(height: 24),
                  CodeField(
                    controller: _code,
                    errorText: _error,
                    onValidated: _submit,
                    autofocus: true,
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Exemple : ${DemoRoom.joinableCode}',
                    style: TextStyle(
                      fontFamily: AppTheme.bodyFont,
                      fontSize: 10,
                      color: AppColors.blueGray,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            ArcadeButton(label: 'Rejoindre', onPressed: _submit),
            const SizedBox(height: 16),
            ArcadeButton(
              label: 'Retour au menu',
              variant: ArcadeButtonVariant.dark,
              fontSize: 24,
              onPressed: () => context.go('/menu'),
            ),
          ],
        ),
      ),
    );
  }
}
