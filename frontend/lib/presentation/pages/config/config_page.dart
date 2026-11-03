import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/widgets/arcade_button.dart';
import '../../../core/widgets/screen_scaffold.dart';
import '../../../domain/categories.dart';
import '../../../domain/rules_config.dart';
import '../../controllers/config_controller.dart';

/// Réglages d'une partie. Les règles restent dans ConfigController.
class ConfigScreen extends StatefulWidget {
  const ConfigScreen({super.key, required this.mode});

  final String mode;

  @override
  State<ConfigScreen> createState() => _ConfigScreenState();
}

class _ConfigScreenState extends State<ConfigScreen> {
  late final ConfigController _config = Get.find<ConfigController>();

  bool get _categoriesValid =>
      _config.randomMode.value ||
      Categories.isValidSelection(_config.selected.toList());

  bool get _canStart =>
      _categoriesValid &&
      (_config.isSolo || _config.nickname.value.trim().isNotEmpty);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final solo = _config.isSolo;
      final random = _config.randomMode.value;

      return ScreenScaffold(
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    TextButton(
                      onPressed: Get.back,
                      child: const Text('Retour'),
                    ),
                    Expanded(
                      child: Text(
                        solo ? 'NOUVELLE PARTIE' : 'MULTIJOUEUR',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                          color: Color(0xFFFFB703),
                        ),
                      ),
                    ),
                    const SizedBox(width: 64),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Wrap(
                spacing: 8,
                children: [
                  ChoiceChip(
                    label: const Text('Aléatoire'),
                    selected: random,
                    selectedColor: const Color(0xFFFFB703),
                    onSelected: (_) => _config.chooseRandom(),
                  ),
                  ChoiceChip(
                    label: const Text('Personnalisé'),
                    selected: !random,
                    selectedColor: const Color(0xFF2EC4B6),
                    onSelected: (_) => _config.chooseCustom(),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                children: [
                  if (!solo)
                    TextField(
                      controller: _config.nicknameController,
                      maxLength: 12,
                      onChanged: _config.setNickname,
                      decoration: InputDecoration(
                        labelText: 'Pseudo',
                        errorText: _config.nicknameError.value,
                        helperText: 'Obligatoire pour créer un salon.',
                        counterText: '',
                        filled: true,
                        fillColor: const Color(0xFF243451),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  const Padding(
                    padding: EdgeInsets.fromLTRB(4, 10, 4, 4),
                    child: Text(
                      'CATÉGORIES OBLIGATOIRES',
                      style: TextStyle(
                        color: Color(0xFFFFB703),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  for (final category in Categories.mandatory)
                    ListTile(
                      dense: true,
                      visualDensity: VisualDensity.compact,
                      leading: const Icon(Icons.lock),
                      title: Text(category),
                      trailing: const Icon(Icons.check),
                    ),
                  const Padding(
                    padding: EdgeInsets.fromLTRB(4, 10, 4, 4),
                    child: Text(
                      'CATÉGORIES FACULTATIVES',
                      style: TextStyle(
                        color: Color(0xFFFFB703),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  for (final category in Categories.optional)
                    CheckboxListTile(
                      dense: true,
                      visualDensity: VisualDensity.compact,
                      title: Text(category),
                      value: _config.selected.contains(category),
                      onChanged: random
                          ? null
                          : (_) => _config.toggle(category),
                    ),
                  Text(
                    random
                        ? '5 catégories fixes et 4 tirées au sort.'
                        : '${_config.selected.length} / ${Categories.maxPerGame} catégories',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFF2EC4B6),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.fromLTRB(4, 16, 4, 8),
                    child: Text(
                      'DURÉE DE LA MANCHE',
                      style: TextStyle(
                        color: Color(0xFFFFB703),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Wrap(
                    spacing: 8,
                    children: [
                      for (final seconds in RulesConfig.turnDurations)
                        ChoiceChip(
                          label: Text(
                            seconds == 0 ? 'Sans chrono' : '$seconds s',
                          ),
                          selected: _config.duration.value == seconds,
                          selectedColor: const Color(0xFF2EC4B6),
                          onSelected: (_) => _config.chooseDuration(seconds),
                        ),
                    ],
                  ),
                  ListTile(
                    title: const Text('Nombre de manches'),
                    subtitle: Text('${_config.rounds.value}'),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed:
                              _config.rounds.value > RulesConfig.minRounds
                              ? () => _config.chooseRounds(
                                  _config.rounds.value - 1,
                                )
                              : null,
                          icon: const Icon(Icons.remove),
                        ),
                        IconButton(
                          onPressed:
                              _config.rounds.value < RulesConfig.maxRounds
                              ? () => _config.chooseRounds(
                                  _config.rounds.value + 1,
                                )
                              : null,
                          icon: const Icon(Icons.add),
                        ),
                      ],
                    ),
                  ),
                  SwitchListTile(
                    title: const Text('Lettres difficiles K, W, X, Y, Z'),
                    value: _config.hardLetters.value,
                    onChanged: _config.toggleHardLetters,
                  ),
                  if (!_categoriesValid)
                    const Text(
                      'Maximum 12 catégories, obligatoires incluses.',
                      textAlign: TextAlign.center,
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: SafeArea(
                top: false,
                child: ArcadeButton(
                  label: solo
                      ? 'Lancer'
                      : _config.isCreatingRoom.value
                      ? 'Création en cours…'
                      : 'Créer le salon',
                  variant: solo
                      ? ArcadeButtonVariant.yellow
                      : ArcadeButtonVariant.teal,
                  onPressed: !_canStart || _config.isCreatingRoom.value
                      ? null
                      : solo
                      ? _config.launchSolo
                      : _config.previewLobby,
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}
