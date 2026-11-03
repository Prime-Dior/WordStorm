import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/arcade_button.dart';
import '../../../core/widgets/code_field.dart';
import '../../../core/widgets/nickname_field.dart';
import '../../../core/widgets/screen_scaffold.dart';
import '../../../core/widgets/ui_kit.dart';
import '../../controllers/page_controllers.dart';

/// Écran « Rejoindre un salon » (maquette 22) : saisie du code
/// d'invitation et du pseudo, bouton REJOINDRE et retour au menu.
/// La recherche du salon passe par l'API ([JoinController.submit]) ;
/// un code inconnu affiche l'erreur sous le champ.
class JoinScreen extends StatefulWidget {
  const JoinScreen({super.key});

  @override
  State<JoinScreen> createState() => _JoinScreenState();
}

class _JoinScreenState extends State<JoinScreen> {
  late final JoinController _controller = Get.find<JoinController>();

  Future<void> _submit() async {
    await _controller.submit();
    if (mounted) setState(() {});
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
            ScreenTitle('Rejoindre un salon', onBack: () => Get.back<void>()),
            const SizedBox(height: 40),
            DarkPanel(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 18),
              child: Obx(
                () => Column(
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
                      controller: _controller.code,
                      errorText: _controller.codeError.value,
                      onChanged: _controller.onCodeChanged,
                      onValidated: _submit,
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'Ton pseudo',
                      style: TextStyle(
                        fontFamily: AppTheme.bodyFont,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.offWhite,
                      ),
                    ),
                    const SizedBox(height: 8),
                    NicknameField(
                      controller: _controller.nickname,
                      errorText: _controller.nicknameError.value,
                      onChanged: (value) {
                        if (value.trim().isNotEmpty &&
                            value.trim().length <= 12) {
                          _controller.nicknameError.value = null;
                        }
                      },
                      onSubmitted: _submit,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Obx(
              () => ArcadeButton(
                label: _controller.isJoining.value ? 'Connexion…' : 'Rejoindre',
                onPressed: _controller.isJoining.value ? null : _submit,
              ),
            ),
            const SizedBox(height: 16),
            ArcadeButton(
              label: 'Retour au menu',
              variant: ArcadeButtonVariant.dark,
              fontSize: 24,
              onPressed: () => Get.offAllNamed<void>('/menu'),
            ),
          ],
        ),
      ),
    );
  }
}
