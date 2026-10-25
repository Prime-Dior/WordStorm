import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/icons/wordstorm_icons.dart';
import '../../core/widgets/screen_scaffold.dart';
import '../../data/settings/settings_repository.dart';

/// Réglages (Figma 18) : pseudo, sons, vibrations, animations réduites
/// — branchés sur `SettingsRepository` (phase 3).
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _nickname = TextEditingController();

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
    final s = ref.read(settingsProvider);
    _nickname.text = await s.nickname();
    _sound = await s.soundOn();
    _vibration = await s.vibrationOn();
    _reduceAnimations = await s.reduceAnimations();
    if (mounted) setState(() => _loaded = true);
  }

  @override
  void dispose() {
    _nickname.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.read(settingsProvider);

    return ScreenScaffold(
      skylineHeight: 220,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'PARAMÈTRES',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: AppTheme.displayFont,
              fontSize: 30,
              color: AppColors.offWhite,
            ),
          ),
          const SizedBox(height: 18),
          Expanded(
            child: !_loaded
                ? const SizedBox.shrink()
                : ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      const _FieldLabel('PSEUDO'),
                      TextField(
                        controller: _nickname,
                        maxLength: 12,
                        decoration: _inputDecoration('Champion'),
                        style: const TextStyle(
                          fontFamily: AppTheme.bodyFont,
                          fontWeight: FontWeight.w600,
                          color: AppColors.navyBlue,
                        ),
                        onChanged: (v) => s.setNickname(v),
                      ),
                      _SwitchRow(
                        icon: 'wave',
                        label: 'Sons',
                        value: _sound,
                        onChange: (v) {
                          setState(() => _sound = v);
                          s.setSoundOn(v);
                        },
                      ),
                      _SwitchRow(
                        icon: 'bolt',
                        label: 'Vibrations',
                        value: _vibration,
                        onChange: (v) {
                          setState(() => _vibration = v);
                          s.setVibrationOn(v);
                        },
                      ),
                      _SwitchRow(
                        icon: 'leaf',
                        label: 'Réduire les animations',
                        value: _reduceAnimations,
                        onChange: (v) {
                          setState(() => _reduceAnimations = v);
                          s.setReduceAnimations(v);
                        },
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) => InputDecoration(
    isDense: true,
    counterText: '',
    filled: true,
    fillColor: AppColors.offWhite,
    hintText: hint,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
  );
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 6, left: 4),
    child: Text(
      label,
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

class _SwitchRow extends StatelessWidget {
  const _SwitchRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.onChange,
  });

  final String icon;
  final String label;
  final bool value;
  final ValueChanged<bool> onChange;

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(top: 12),
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    decoration: BoxDecoration(
      color: const Color(0x14FFFFFF),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      children: [
        WordstormIcons.gear(size: 20, color: AppColors.blueGray),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontFamily: AppTheme.bodyFont,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.offWhite,
            ),
          ),
        ),
        Switch(value: value, onChanged: onChange),
      ],
    ),
  );
}
