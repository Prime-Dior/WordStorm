/// Sons générés (phase 6 — cahier §5.2 « sons, vibrations »).
///
/// Aucun asset binaire : chaque son est un **WAV PCM 16 bits mono
/// synthétisé à l'exécution** (sine avec enveloppe anti-clic), joué par
/// `audioplayers` via `BytesSource`. Le réglage local `soundOn` (phase 3)
/// gouverne tout ; les erreurs de lecture et de vibration sont
/// best-effort (une plateforme sans audio ne doit jamais faire planter
/// le jeu — y compris dans les tests où le plugin n'existe pas).
library;

import 'dart:async';
import 'dart:math';
import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

const int _sampleRate = 22050; // suffisant pour des tones, taille /2.

/// Les sons joués dans l'app (PLAN phase 6 : roue, démarrage,
/// 5 dernières secondes, validation, victoire).
enum SoundCue {
  /// La roue tourne (glissando descendant, fin sur l'arrêt).
  wheel,

  /// Une manche démarre (deux notes montantes).
  start,

  /// Blip du compte à rebours dans les 5 dernières secondes.
  tick,

  /// VALIDER / STOP (arpège majeur).
  validate,

  /// Fin de partie (fanfare courte).
  victory,
}

/// Synthèse WAV : notes = sine (éventuellement glissando) avec fondu
/// linéaire de 8 ms aux deux extrémités (anti-clic).
@immutable
class WavTone {
  const WavTone._();

  /// Génère le WAV complet (44 octets d'en-tête + PCM).
  static Uint8List synth({
    required List<(double, int)> notes, // (fréquence Hz, durée ms)
    double volume = 0.5,
    double? endFrequency, // si défini : glissando linéaire sur chaque note.
  }) {
    final samples = <int>[];
    for (final (freq, ms) in notes) {
      samples.addAll(_note(freq, ms, volume, endFrequency ?? freq));
    }
    return _wav(samples);
  }

  static List<int> _note(
    double fromFreq,
    int ms,
    double volume,
    double toFreq,
  ) {
    final n = (_sampleRate * ms / 1000).round();
    final fade = (_sampleRate * 8 / 1000).round().clamp(1, n ~/ 2);
    final out = <int>[];
    var phase = 0.0;
    for (var i = 0; i < n; i++) {
      final t = i / n;
      final freq = fromFreq + (toFreq - fromFreq) * t;
      phase += 2 * pi * freq / _sampleRate;
      // Enveloppe linéaire d'attaque/descente (anti-clic).
      var env = 1.0;
      if (i < fade) {
        env = i / fade;
      } else if (i > n - fade) {
        env = (n - i) / fade;
      }
      final v = (sin(phase) * volume * env).clamp(-1.0, 1.0);
      out.add((v * 32767).round());
    }
    return out;
  }

  static Uint8List _wav(List<int> samples) {
    final dataBytes = samples.length * 2;
    final b = BytesBuilder();
    // En-tête RIFF/WAVE canonique.
    b.add(
      Uint8List.fromList([
        0x52, 0x49, 0x46, 0x46, // 'RIFF'
        ..._u32(36 + dataBytes),
        0x57, 0x41, 0x56, 0x45, // 'WAVE'
        0x66, 0x6D, 0x74, 0x20, // 'fmt '
        ..._u32(16), // taille fmt
        0x01, 0x00, // PCM
        0x01, 0x00, // mono
        ..._u32(_sampleRate),
        ..._u32(_sampleRate * 2), // byte rate
        0x02, 0x00, // block align
        0x10, 0x00, // bits/sample
        0x64, 0x61, 0x74, 0x61, // 'data'
        ..._u32(dataBytes),
      ]),
    );
    for (final s in samples) {
      b.add(Uint16List.fromList([s & 0xFFFF]).buffer.asUint8List());
    }
    return b.takeBytes();
  }

  static List<int> _u32(int v) => [
    v & 0xFF,
    (v >> 8) & 0xFF,
    (v >> 16) & 0xFF,
    (v >> 24) & 0xFF,
  ];
}

/// Lecteur des sons générés. Injecter un booléen d'activation (réglage
/// local) ; en tests aucun plugin audio n'existe : tout est try/catch.
class SoundEngine {
  SoundEngine({Future<bool> Function()? soundOn})
    : _soundOn = soundOn ?? (() async => true);

  final Future<bool> Function() _soundOn;

  /// Cache des bytes générés (CPU nul à la répétition).
  final Map<SoundCue, Uint8List> _cache = {};

  Future<void> play(SoundCue cue) async {
    try {
      if (!await _soundOn()) return;
      final bytes = bytesFor(cue);
      final player = AudioPlayer();
      // Décharge le lecteur après la lecture (les sons durent < 1 s).
      unawaited(player.onPlayerComplete.first.then((_) => player.dispose()));
      await player.play(BytesSource(bytes));
    } catch (_) {
      // Best-effort : pas de son ne peut casser le flux de jeu.
    }
  }

  Uint8List bytesFor(SoundCue cue) => _cache.putIfAbsent(cue, () {
    switch (cue) {
      case SoundCue.wheel:
        // Glissando descendant : la roue ralentit sur ~0,9 s.
        return WavTone.synth(
          notes: const [(760, 900)],
          volume: 0.4,
          endFrequency: 120,
        );
      case SoundCue.start:
        // Deux notes montantes.
        return WavTone.synth(notes: const [(440, 110), (880, 170)]);
      case SoundCue.tick:
        return WavTone.synth(notes: const [(1180, 70)]);
      case SoundCue.validate:
        // Arpège majeur do-mi-sol.
        return WavTone.synth(notes: const [(523, 90), (659, 90), (784, 180)]);
      case SoundCue.victory:
        // Fanfare do-mi-sol-do.
        return WavTone.synth(
          notes: const [(523, 140), (659, 140), (784, 140), (1047, 340)],
          volume: 0.55,
        );
    }
  });
}

/// Vibrations via `HapticFeedback`, gouvernées par le réglage local.
/// Toujours try/catch : aucune plateforme de vibration dans les tests.
class VibrationEngine {
  VibrationEngine({Future<bool> Function()? vibrationOn})
    : _vibrationOn = vibrationOn ?? (() async => true);

  final Future<bool> Function() _vibrationOn;

  Future<void> light() => _fire(HapticFeedback.lightImpact);
  Future<void> medium() => _fire(HapticFeedback.mediumImpact);
  Future<void> heavy() => _fire(HapticFeedback.heavyImpact);

  Future<void> _fire(Future<void> Function() haptic) async {
    try {
      if (!await _vibrationOn()) return;
      await haptic();
    } catch (_) {
      // Best-effort.
    }
  }
}
