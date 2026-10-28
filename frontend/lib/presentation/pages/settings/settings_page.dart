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
            color: const Color(0xEE17223A),
            borderRadius: BorderRadius.circular(22),
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
                            fontSize: 28,
                            color: AppColors.offWhite,
                          ),
                        ),
                        const SizedBox(height: 10),
                        _OptionRow(
                          label: 'Sons',
                          value: _controller.sound.value,
                          onChanged: _controller.setSound,
                        ),
                        _OptionRow(
                          label: 'Vibrations (si le mobile le permet)',
                          value: _controller.vibration.value,
                          onChanged: _controller.setVibration,
                        ),
                        _OptionRow(
                          label: 'Réduire les animations',
                          value: _controller.reduceAnimations.value,
                          onChanged: _controller.setReduceAnimations,
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

class _OptionRow extends StatelessWidget {
  const _OptionRow({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 8),
    child: Material(
      color: const Color(0xCC38475F),
      borderRadius: BorderRadius.circular(11),
      clipBehavior: Clip.antiAlias,
      child: CheckboxListTile(
        value: value,
        onChanged: (v) => onChanged(v ?? false),
        mouseCursor: SystemMouseCursors.click,
        activeColor: AppColors.yellow,
        checkColor: AppColors.navyBlue,
        controlAffinity: ListTileControlAffinity.leading,
        dense: true,
        visualDensity: VisualDensity.compact,
        contentPadding: const EdgeInsets.symmetric(horizontal: 8),
        title: Text(
          label,
          style: const TextStyle(
            fontFamily: AppTheme.bodyFont,
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.offWhite,
          ),
        ),
      ),
    ),
  );
}
