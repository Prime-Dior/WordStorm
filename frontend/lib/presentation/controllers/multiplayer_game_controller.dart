import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/routes/app_routes.dart';
import '../../data/api/api_client.dart';
import '../../data/repository/room_repository.dart';
import '../../domain/models/multiplayer_round_session.dart';
import '../../domain/models/round_model.dart';

class MultiplayerGameController extends GetxController {
  late final MultiplayerRoundSession session =
      Get.arguments as MultiplayerRoundSession;
  late final Rx<RoundModel> round = session.round.obs;

  final secondsRemaining = 0.obs;
  final formRevision = 0.obs;
  final isSaving = false.obs;
  final isLocking = false.obs;
  final isGameFinished = false.obs;
  final error = RxnString();
  final answers = <String, TextEditingController>{};

  Timer? _clockTimer;
  Timer? _pollTimer;
  bool _lockRequested = false;
  bool _routeRequested = false;

  bool get hasTimer => session.durationSeconds > 0;

  bool get canEdit =>
      round.value.status == 'active' &&
      (!hasTimer || secondsRemaining.value > 0) &&
      !isSaving.value &&
      !isLocking.value;

  bool get allCategoriesFilled =>
      answers.values.every((controller) => controller.text.trim().isNotEmpty);

  void answerChanged(String value) {
    formRevision.value++;
  }

  @override
  void onInit() {
    super.onInit();
    for (final category in session.categories) {
      answers[category] = TextEditingController();
    }
    _updateCountdown();
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _updateCountdown();
      if (hasTimer &&
          secondsRemaining.value == 0 &&
          round.value.status == 'active') {
        _lockRound();
      }
    });
    _pollTimer = Timer.periodic(
      const Duration(seconds: 2),
      (_) => _pollState(),
    );
    _pollState();
  }

  void _updateCountdown() {
    if (!hasTimer || round.value.endsAt == null) {
      secondsRemaining.value = 0;
      return;
    }

    final remainingMilliseconds = round.value.endsAt!
        .difference(DateTime.now())
        .inMilliseconds;
    secondsRemaining.value = remainingMilliseconds <= 0
        ? 0
        : (remainingMilliseconds / 1000).ceil();
  }

  Future<void> submitAnswers() async {
    if (!canEdit) return;

    if (!hasTimer && session.isHost && !allCategoriesFilled) {
      Get.snackbar(
        'Réponses incomplètes',
        'Remplis toutes les catégories avant d’arrêter la manche.',
      );
      return;
    }

    isSaving.value = true;
    error.value = null;

    try {
      final values = <String, String?>{
        for (final entry in answers.entries)
          entry.key: entry.value.text.trim().isEmpty
              ? null
              : entry.value.text.trim(),
      };

      round.value = await Get.find<RoomRepository>().submitAnswers(
        session.roomCode,
        round.value.number,
        values,
      );

      if (!hasTimer && session.isHost) {
        await _lockRound();
      } else {
        Get.snackbar('Réponses enregistrées', 'Tu peux encore les modifier.');
      }
    } on ApiException catch (exception) {
      error.value = exception.message;
    } catch (_) {
      error.value = 'Les réponses n’ont pas pu être envoyées.';
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> _lockRound() async {
    if (_lockRequested || round.value.status != 'active') return;
    _lockRequested = true;
    isLocking.value = true;

    try {
      round.value = await Get.find<RoomRepository>().lockRound(
        session.roomCode,
        round.value.number,
      );
      _updateCountdown();
      await _checkForNextRound();
    } on ApiException catch (exception) {
      if (exception.statusCode == 409) {
        try {
          round.value = await Get.find<RoomRepository>().getRound(
            session.roomCode,
            round.value.number,
          );
          if (round.value.status == 'completed') {
            await _checkForNextRound();
          } else {
            error.value = exception.message;
            _lockRequested = false;
          }
        } catch (_) {
          error.value = exception.message;
          _lockRequested = false;
        }
      } else {
        error.value = exception.message;
        _lockRequested = false;
      }
    } catch (_) {
      error.value = 'La manche n’a pas pu être arrêtée.';
      _lockRequested = false;
    } finally {
      isLocking.value = false;
    }
  }

  Future<void> _pollState() async {
    if (round.value.status == 'completed') {
      await _checkForNextRound();
      return;
    }

    try {
      round.value = await Get.find<RoomRepository>().getRound(
        session.roomCode,
        round.value.number,
      );
      _updateCountdown();
      if (round.value.status == 'completed') {
        await _checkForNextRound();
      }
    } on ApiException catch (exception) {
      error.value = exception.message;
    } catch (_) {
      error.value = 'Impossible de récupérer l’état de la manche.';
    }
  }

  Future<void> _checkForNextRound() async {
    if (_routeRequested) return;

    try {
      final room = await Get.find<RoomRepository>().getRoom(session.roomCode);
      if (room.status == 'finished') {
        isGameFinished.value = true;
        _pollTimer?.cancel();
        return;
      }

      final nextRounds = room.rounds
          .where(
            (candidate) =>
                candidate.number > round.value.number &&
                candidate.status == 'active',
          )
          .toList(growable: false);
      if (nextRounds.isEmpty) return;

      _routeRequested = true;
      Get.offNamed<void>(
        AppRoutes.multiplayerGame,
        arguments: MultiplayerRoundSession.fromRoom(
          room: room,
          round: nextRounds.first,
          nickname: session.nickname,
          isHost: session.isHost,
        ),
      );
    } on ApiException catch (exception) {
      error.value = exception.message;
    } catch (_) {
      error.value = 'Impossible de vérifier la manche suivante.';
    }
  }

  Future<void> startNextRound() async {
    if (!session.isHost || isSaving.value || isLocking.value) return;

    isSaving.value = true;
    error.value = null;

    try {
      final nextNumber = round.value.number + 1;
      final nextRound = await Get.find<RoomRepository>().beginRound(
        session.roomCode,
        nextNumber,
      );
      final room = await Get.find<RoomRepository>().getRoom(session.roomCode);

      Get.offNamed<void>(
        AppRoutes.multiplayerGame,
        arguments: MultiplayerRoundSession.fromRoom(
          room: room,
          round: nextRound,
          nickname: session.nickname,
          isHost: session.isHost,
        ),
      );
    } on ApiException catch (exception) {
      error.value = exception.message;
    } catch (_) {
      error.value = 'La manche suivante n’a pas pu démarrer.';
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> returnToMenu() async {
    try {
      await Get.find<RoomRepository>().leaveRoom(session.roomCode);
    } catch (_) {
      // Le retour au menu reste possible si la connexion est perdue.
    } finally {
      Get.offAllNamed<void>(AppRoutes.menu);
    }
  }

  @override
  void onClose() {
    _clockTimer?.cancel();
    _pollTimer?.cancel();
    for (final controller in answers.values) {
      controller.dispose();
    }
    super.onClose();
  }
}
