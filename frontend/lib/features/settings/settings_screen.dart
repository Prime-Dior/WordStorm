import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/arcade_button.dart';
import '../../core/widgets/ui_kit.dart';
import '../../data/settings/settings_repository.dart';
import '../skeleton/status_screen.dart';

/// Fenêtre Paramètres (maquette 18), au-dessus du menu.
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _sound = SettingsRepository.kDefaultSound;
  bool _vibration = SettingsRepository.kDefaultVibration;
  bool _reduceAnimations = SettingsRepository.kDefaultReduceAnimations;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final settings = ref.read(settingsProvider);
    _sound = await settings.soundOn();
    _vibration = await settings.vibrationOn();
    _reduceAnimations = await settings.reduceAnimations();
    if (mounted) setState(() => _loaded = true);
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.read(settingsProvider);
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 350, maxHeight: 650),
        child: Material(
          type: MaterialType.transparency,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 20, 18, 16),
            child: !_loaded
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
                      _OptionRow(
                        label: 'Sons',
                        value: _sound,
                        onChanged: (v) {
                          setState(() => _sound = v);
                          settings.setSoundOn(v);
                        },
                      ),
                      _OptionRow(
                        label: 'Vibrations (si le mobile le permet)',
                        value: _vibration,
                        onChanged: (v) {
                          setState(() => _vibration = v);
                          settings.setVibrationOn(v);
                        },
                      ),
                      _OptionRow(
                        label: 'Réduire les animations',
                        value: _reduceAnimations,
                        onChanged: (v) {
                          setState(() => _reduceAnimations = v);
                          settings.setReduceAnimations(v);
                        },
                      ),
                      const SizedBox(height: 12),
                      ArcadeButton(
                        label: 'Règles du jeu',
                        variant: ArcadeButtonVariant.dark,
                        small: true,
                        onPressed: () => context.push('/rules'),
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
                        onPressed: () => context.pop(),
                      ),
                    ],
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
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: CheckOptionRow(label: label, value: value, onChanged: onChanged),
  );
}
