import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/arcade_button.dart';
import '../../../core/widgets/code_field.dart';
import '../../../core/widgets/screen_scaffold.dart';
import '../../../core/widgets/wordstorm_logo.dart';
import '../../controllers/page_controllers.dart';

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
  late final JoinController _controller = Get.find<JoinController>();

  void _submit() {
    _controller.submit();
    setState(() {});
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
              controller: _controller.code,
              errorText: _controller.error.value,
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
              controller: _controller.nickname,
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
