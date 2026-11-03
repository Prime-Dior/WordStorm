import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/arcade_button.dart';
import '../../../core/widgets/code_field.dart';
import '../../../core/widgets/screen_scaffold.dart';
import '../../../core/widgets/wordstorm_logo.dart';
import '../../controllers/menu_controller.dart' as page_menu;

/// Menu : choisir un mode ou rejoindre un salon avec son code.
class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<page_menu.MenuController>();

    return ScreenScaffold(
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeOutCubic,
        builder: (context, value, child) => Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 12 * (1 - value)),
            child: child,
          ),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const WordstormLogo(width: 126),
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
                      const SizedBox(height: 6),
                      const Row(
                        children: [
                          CircleAvatar(
                            radius: 17,
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
                      const SizedBox(height: 22),
                      const Text(
                        'Choisis ton mode de jeu',
                        style: TextStyle(
                          color: AppColors.offWhite,
                          fontSize: 21,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 14),
                      ArcadeButton(
                        label: 'Solo',
                        onPressed: controller.openSolo,
                      ),
                      const SizedBox(height: 12),
                      ArcadeButton(
                        label: 'Multijoueur',
                        variant: ArcadeButtonVariant.teal,
                        onPressed: controller.openMultiplayer,
                      ),
                      const SizedBox(height: 24),
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
                              controller: controller.codeController,
                              onValidated: controller.join,
                              trailing: Padding(
                                padding: const EdgeInsets.only(left: 8),
                                child: ArcadeButton(
                                  label: 'OK',
                                  small: true,
                                  onPressed: controller.join,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      ArcadeButton(
                        label: 'Classement',
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
      ),
    );
  }
}
