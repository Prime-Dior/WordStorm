import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/widgets/arcade_button.dart';
import '../../../core/widgets/code_field.dart';
import '../../../core/widgets/nickname_field.dart';
import '../../../core/widgets/screen_scaffold.dart';
import '../../../core/widgets/ui_kit.dart';
import '../../controllers/page_controllers.dart';

/// Saisie du code et du pseudo avant de rejoindre un salon.
class JoinScreen extends StatelessWidget {
  const JoinScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<JoinController>();

    return ScreenScaffold(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ScreenTitle('Rejoindre un salon', onBack: () => Get.back<void>()),
            const SizedBox(height: 20),
            Card(
              color: const Color(0xFF152440),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Obx(
                  () => Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text('Code d’invitation'),
                      const SizedBox(height: 8),
                      CodeField(
                        controller: controller.code,
                        errorText: controller.codeError.value,
                        onChanged: controller.onCodeChanged,
                        onValidated: () => controller.submit(),
                      ),
                      const SizedBox(height: 16),
                      NicknameField(
                        controller: controller.nickname,
                        errorText: controller.nicknameError.value,
                        onChanged: (value) {
                          if (value.trim().isNotEmpty &&
                              value.trim().length <= 12) {
                            controller.nicknameError.value = null;
                          }
                        },
                        onSubmitted: () => controller.submit(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Obx(
              () => ArcadeButton(
                label: controller.isJoining.value ? 'Connexion…' : 'Rejoindre',
                onPressed: controller.isJoining.value
                    ? null
                    : controller.submit,
              ),
            ),
            const SizedBox(height: 10),
            ArcadeButton(
              label: 'Retour au menu',
              variant: ArcadeButtonVariant.dark,
              onPressed: () => Get.offAllNamed<void>('/menu'),
            ),
          ],
        ),
      ),
    );
  }
}
