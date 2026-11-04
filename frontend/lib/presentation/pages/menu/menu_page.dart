import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/arcade_button.dart';
import '../../../core/widgets/code_field.dart';
import '../../../core/widgets/screen_scaffold.dart';
import '../../../core/widgets/wordstorm_logo.dart';
import '../../controllers/menu_controller.dart' as page_menu;

/// Menu pour choisir un mode ou rejoindre un salon.
class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  final codeController = TextEditingController();

  @override
  void dispose() {
    codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<page_menu.MenuController>();

    return ScreenScaffold(
      padding: const EdgeInsets.fromLTRB(18, 2, 18, 18),
      child: LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const WordstormLogo(width: 160),
                        IconButton(
                          tooltip: 'Paramètres',
                          onPressed: controller.openSettings,
                          style: IconButton.styleFrom(
                            backgroundColor: AppColors.navyBlue,
                            foregroundColor: AppColors.yellow,
                          ),
                          icon: const Icon(Icons.settings_outlined),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundImage: AssetImage(
                            'assets/images/avatar_toi.png',
                          ),
                        ),
                        SizedBox(width: 10),
                        Text(
                          'Salut, champion !',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    const Text(
                      'Choisis ton mode de jeu',
                      style: TextStyle(
                        color: AppColors.offWhite,
                        fontSize: 21,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 18),
                    ArcadeButton(label: 'Solo', onPressed: controller.openSolo),
                    const SizedBox(height: 16),
                    ArcadeButton(
                      label: 'Multijoueur',
                      variant: ArcadeButtonVariant.teal,
                      onPressed: controller.openMultiplayer,
                    ),
                    const SizedBox(height: 30),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.navyBlue.withValues(alpha: 0.75),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.offWhite.withValues(alpha: 0.12),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            'Rejoindre avec un code',
                            style: TextStyle(
                              color: AppColors.yellow,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          CodeField(
                            controller: codeController,
                            onValidated: () =>
                                controller.join(codeController.text),
                            trailing: Padding(
                              padding: const EdgeInsets.only(left: 8),
                              child: ArcadeButton(
                                label: 'OK',
                                small: true,
                                onPressed: () =>
                                    controller.join(codeController.text),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    ArcadeButton(
                      label: 'Historique',
                      small: true,
                      variant: ArcadeButtonVariant.dark,
                      onPressed: controller.openHistory,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
