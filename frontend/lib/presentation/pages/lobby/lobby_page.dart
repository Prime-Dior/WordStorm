import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/salon_code.dart';
import '../../../core/widgets/arcade_button.dart';
import '../../../core/widgets/player_card.dart';
import '../../../core/widgets/screen_scaffold.dart';
import '../../../domain/models/lobby_setup.dart';
import '../../controllers/page_controllers.dart';

/// Prévisualisation de l'écran de salon prévu par la maquette.
/// Le code et le joueur hôte sont locaux ; aucun salon en ligne n'est créé.
class LobbyScreen extends StatefulWidget {
  const LobbyScreen({super.key, this.setup});

  final LobbySetup? setup;

  @override
  State<LobbyScreen> createState() => _LobbyScreenState();
}

class _LobbyScreenState extends State<LobbyScreen> {
  late final String _code;

  LobbySetup? get _setup =>
      widget.setup ??
      Get.find<LobbyController>().setup ??
      const LobbySetup(
        categories: ['Prénom', 'Ville', 'Pays', 'Animal', 'Objet'],
        durationSeconds: 60,
        rounds: 3,
        allowHardLetters: false,
        randomCategories: false,
      );

  @override
  void initState() {
    super.initState();
    _code = SalonCode.generate(Random.secure());
  }

  Future<void> _copyCode() async {
    await Clipboard.setData(ClipboardData(text: _code));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Code copié (aperçu local uniquement).')),
    );
  }

  String _durationLabel(int seconds) =>
      seconds == 0 ? 'Sans chrono' : '$seconds s / manche';

  @override
  Widget build(BuildContext context) {
    final setup = _setup!;
    return ScreenScaffold(
      skylineHeight: 250,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              IconButton(
                tooltip: 'Retour à la configuration',
                onPressed: () => Get.back(),
                icon: const Icon(Icons.arrow_back, color: AppColors.offWhite),
              ),
              const Expanded(
                child: Text(
                  'SALON MULTIJOUEUR',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: AppTheme.displayFont,
                    fontSize: 26,
                    color: AppColors.offWhite,
                  ),
                ),
              ),
              const SizedBox(width: 48),
            ],
          ),
          const SizedBox(height: 14),
          _CodePanel(code: _code, onCopy: _copyCode),
          const SizedBox(height: 14),
          const Row(
            children: [
              Expanded(
                child: Text(
                  'JOUEURS',
                  style: TextStyle(
                    fontFamily: AppTheme.displayFont,
                    fontSize: 21,
                    color: AppColors.yellow,
                  ),
                ),
              ),
              Text(
                '1 / 8 joueurs',
                style: TextStyle(
                  fontFamily: AppTheme.bodyFont,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                  color: AppColors.blueGray,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const PlayerCard(
            name: 'Toi · Hôte',
            host: true,
            avatar: 'assets/images/avatar_toi.png',
          ),
          const SizedBox(height: 7),
          const _EmptyPlacesPreview(),
          const SizedBox(height: 12),
          Expanded(
            child: SingleChildScrollView(
              child: _SetupSummary(
                setup: setup,
                durationLabel: _durationLabel(setup.durationSeconds),
              ),
            ),
          ),
          const SizedBox(height: 8),
          const ArcadeButton(
            label: 'Démarrer · 1 joueur',
            variant: ArcadeButtonVariant.teal,
          ),
          const SizedBox(height: 8),
          ArcadeButton(
            label: 'Quitter le salon',
            variant: ArcadeButtonVariant.dark,
            small: true,
            onPressed: () => Get.offAllNamed('/menu'),
          ),
        ],
      ),
    );
  }
}

class _CodePanel extends StatelessWidget {
  const _CodePanel({required this.code, required this.onCopy});

  final String code;
  final VoidCallback onCopy;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
    decoration: BoxDecoration(
      color: const Color(0xCC000000),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: const Color(0x33FFFFFF)),
    ),
    child: Row(
      children: [
        const Expanded(
          child: Text(
            'CODE DU SALON',
            style: TextStyle(
              fontFamily: AppTheme.bodyFont,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.blueGray,
            ),
          ),
        ),
        Text(
          code,
          style: const TextStyle(
            fontFamily: AppTheme.monoFont,
            fontSize: 23,
            fontWeight: FontWeight.w700,
            letterSpacing: 3,
            color: AppColors.yellow,
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          tooltip: 'Copier le code local',
          onPressed: onCopy,
          icon: const Icon(Icons.copy, color: AppColors.offWhite, size: 20),
        ),
      ],
    ),
  );
}

/// Indique combien de places restent dans le salon.
class _EmptyPlacesPreview extends StatelessWidget {
  const _EmptyPlacesPreview();

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
    decoration: BoxDecoration(
      color: const Color(0x12FFFFFF),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: const Color(0x22FFFFFF)),
    ),
    child: const Row(
      children: [
        Icon(Icons.group_outlined, color: AppColors.blueGray, size: 20),
        SizedBox(width: 8),
        Expanded(
          child: Text(
            '7 places libres',
            style: TextStyle(
              fontFamily: AppTheme.bodyFont,
              fontSize: 11,
              color: AppColors.blueGray,
            ),
          ),
        ),
      ],
    ),
  );
}

class _SetupSummary extends StatelessWidget {
  const _SetupSummary({required this.setup, required this.durationLabel});

  final LobbySetup setup;
  final String durationLabel;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: const Color(0x14FFFFFF),
      borderRadius: BorderRadius.circular(14),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'PARAMÈTRES DE LA PARTIE',
          style: TextStyle(
            fontFamily: AppTheme.displayFont,
            fontSize: 18,
            color: AppColors.teal,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          '${setup.rounds} manche${setup.rounds == 1 ? '' : 's'} · $durationLabel',
          style: const TextStyle(
            fontFamily: AppTheme.bodyFont,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.offWhite,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Catégories ${setup.randomCategories ? 'aléatoires (figées)' : 'personnalisées'} · '
          'lettres difficiles ${setup.allowHardLetters ? 'activées' : 'désactivées'}',
          style: const TextStyle(
            fontFamily: AppTheme.bodyFont,
            fontSize: 11,
            color: AppColors.blueGray,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: setup.categories
              .map((category) => _CategoryChip(category))
              .toList(growable: false),
        ),
      ],
    ),
  );
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip(this.label);

  final String label;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: AppColors.navyBlue,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: AppColors.teal.withAlpha(0x88)),
    ),
    child: Text(
      label,
      style: const TextStyle(
        fontFamily: AppTheme.bodyFont,
        fontSize: 10,
        color: AppColors.offWhite,
      ),
    ),
  );
}
