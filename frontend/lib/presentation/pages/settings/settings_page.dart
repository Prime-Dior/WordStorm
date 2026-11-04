import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/arcade_button.dart';
import '../../controllers/settings_controller.dart';
import '../status/status_page.dart';

/// Fenêtre Paramètres (maquette 18), au-dessus du menu.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late final SettingsController _controller = Get.find<SettingsController>();

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 350, maxHeight: 650),
          child: Material(
            type: MaterialType.transparency,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 20, 18, 16),
              child: !_controller.loaded.value
                  ? const Center(child: CircularProgressIndicator())
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'PARAMÈTRES',
                          style: TextStyle(
                            fontFamily: AppTheme.displayFont,
                            fontSize: 30,
                            color: AppColors.offWhite,
                            shadows: [
                              Shadow(
                                color: Color(0xFF0C1429),
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        SwitchListTile(
                          title: const Text('Sons'),
                          value: _controller.sound.value,
                          onChanged: _controller.setSound,
                          activeTrackColor: AppColors.teal,
                        ),
                        SwitchListTile(
                          title: const Text('Vibrations'),
                          value: _controller.vibration.value,
                          onChanged: _controller.setVibration,
                          activeTrackColor: AppColors.teal,
                        ),
                        SwitchListTile(
                          title: const Text('Réduire les animations'),
                          value: _controller.reduceAnimations.value,
                          onChanged: _controller.setReduceAnimations,
                          activeTrackColor: AppColors.teal,
                        ),
                        const SizedBox(height: 12),
                        ArcadeButton(
                          label: 'Règles du jeu',
                          variant: ArcadeButtonVariant.dark,
                          small: true,
                          onPressed: _controller.openRules,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Démonstration',
                          style: TextStyle(
                            fontFamily: AppTheme.bodyFont,
                            fontSize: 11,
                            color: AppColors.blueGray,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const StatusDemoButtons(),
                        const SizedBox(height: 12),
                        ArcadeButton(
                          label: 'Fermer',
                          variant: ArcadeButtonVariant.dark,
                          small: true,
                          onPressed: _controller.close,
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
