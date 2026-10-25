import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/arcade_button.dart';
import '../../core/widgets/screen_scaffold.dart';
import '../../data/history/history_repository.dart';

/// Historique personnel (phase 6 — cahier §5.1 « historique » et §5.2
/// « statistiques »). Persistance locale via `HistoryRepository` ; pas de
/// classement global (décision ANALYSE §5-10 : pas de serveur ici).
class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  List<GameRecord>? _records;
  bool _cleared = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final records = await ref.read(historyProvider).all();
    if (mounted) setState(() => _records = records);
  }

  Future<void> _confirmClear() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.darkButton,
        title: const Text(
          'Effacer l\'historique ?',
          style: TextStyle(
            fontFamily: AppTheme.bodyFont,
            fontWeight: FontWeight.w700,
            color: AppColors.offWhite,
          ),
        ),
        content: const Text(
          'Toutes tes parties enregistrées seront supprimées.',
          style: TextStyle(
            fontFamily: AppTheme.bodyFont,
            color: AppColors.blueGray,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Effacer'),
          ),
        ],
      ),
    );
    if (ok ?? false) {
      await ref.read(historyProvider).clear();
      if (mounted) setState(() => _cleared = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final records = _records;

    return ScreenScaffold(
      skylineHeight: 220,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'TON HISTORIQUE',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: AppTheme.displayFont,
              fontSize: 30,
              color: AppColors.yellow,
            ),
          ),
          const SizedBox(height: 14),
          Expanded(
            child: records == null
                ? const SizedBox.shrink()
                : records.isEmpty
                ? _empty()
                : _list(records),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ArcadeButton(
                label: 'Menu',
                small: true,
                onPressed: () => context.push('/menu'),
              ),
              // Caché tant que l'historique est vide (ou vient d'être
              // effacé) : pas d'action destructrice disponible à vide.
              if (records != null && records.isNotEmpty && !_cleared)
                ArcadeButton(
                  label: 'Effacer',
                  small: true,
                  onPressed: _confirmClear,
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _empty() => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'AUCUNE PARTIE',
          style: TextStyle(
            fontFamily: AppTheme.displayFont,
            fontSize: 20,
            color: AppColors.offWhite,
          ),
        ),
        const SizedBox(height: 8),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Joue une partie en solo : elle sera enregistrée ici '
            'automatiquement à la fin.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: AppTheme.bodyFont,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              height: 1.5,
              color: AppColors.blueGray,
            ),
          ),
        ),
        const SizedBox(height: 20),
        ArcadeButton(
          label: 'JOUER',
          small: true,
          onPressed: () => context.push('/menu'),
        ),
      ],
    ),
  );

  Widget _list(List<GameRecord> records) {
    final stats = LocalHistoryRepository.statsOf(records);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── Statistiques (cahier §5.2) ────────────────────────────────
        Row(
          children: [
            _StatCard(label: 'PARTIES', value: stats.games),
            const SizedBox(width: 8),
            _StatCard(label: 'MEILLEUR', value: stats.bestScore),
            const SizedBox(width: 8),
            _StatCard(label: 'MOYENNE', value: stats.averageScore),
          ],
        ),
        const SizedBox(height: 12),
        // ── Liste des parties, du plus récent ────────────────────────
        Expanded(
          child: ListView.separated(
            padding: EdgeInsets.zero,
            itemCount: records.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, i) => _RecordTile(record: records[i]),
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value});

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0x14FFFFFF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            '$value',
            style: const TextStyle(
              fontFamily: AppTheme.displayFont,
              fontSize: 22,
              color: AppColors.teal,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontFamily: AppTheme.bodyFont,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: .8,
              color: AppColors.blueGray,
            ),
          ),
        ],
      ),
    ),
  );
}

class _RecordTile extends StatelessWidget {
  const _RecordTile({required this.record});

  final GameRecord record;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    decoration: BoxDecoration(
      color: const Color(0x14FFFFFF),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      children: [
        // Total de la partie.
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${record.totalScore}',
              style: const TextStyle(
                fontFamily: AppTheme.displayFont,
                fontSize: 20,
                color: AppColors.yellow,
              ),
            ),
            const Text(
              'PTS',
              style: TextStyle(
                fontFamily: AppTheme.bodyFont,
                fontSize: 9,
                fontWeight: FontWeight.w700,
                letterSpacing: .8,
                color: AppColors.blueGray,
              ),
            ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                record.dateLabel,
                style: const TextStyle(
                  fontFamily: AppTheme.bodyFont,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.offWhite,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${record.mode == 'solo' ? 'Solo' : 'Multijoueur'} · '
                '${record.rounds} manche${record.rounds > 1 ? 's' : ''}',
                style: const TextStyle(
                  fontFamily: AppTheme.bodyFont,
                  fontSize: 12,
                  color: AppColors.blueGray,
                ),
              ),
            ],
          ),
        ),
        // Lettres tirées, dans l'ordre.
        for (final letter in record.letters.take(8))
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Container(
              width: 24,
              height: 28,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.darkButton,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                letter,
                style: const TextStyle(
                  fontFamily: AppTheme.displayFont,
                  fontSize: 14,
                  color: AppColors.offWhite,
                ),
              ),
            ),
          ),
      ],
    ),
  );
}
