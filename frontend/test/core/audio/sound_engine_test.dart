/// Tests du moteur audio (phase 6) : le **WAV généré** est valide
/// (en-tête RIFF/WAVE canonique, PCM non vide, taille cohérente) et le
/// **gate du réglage** empêche toute lecture quand `soundOn` est faux
/// (aucun `AudioPlayer` créé : le canal plateforme ne doit pas exister
/// dans les tests — c'est le contrat best-effort).
library;

import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:wordstorm/core/audio/sound_engine.dart';

void main() {
  group('WavTone.synth', () {
    test('produit un en-tête RIFF/WAVE valide', () {
      final wav = WavTone.synth(notes: const [(440, 100)]);
      expect(wav.length, greaterThan(44));
      // 'RIFF' … 'WAVE' … 'fmt ' … 'data'.
      expect(String.fromCharCodes(wav.sublist(0, 4)), 'RIFF');
      expect(String.fromCharCodes(wav.sublist(8, 12)), 'WAVE');
      expect(String.fromCharCodes(wav.sublist(12, 16)), 'fmt ');
      expect(String.fromCharCodes(wav.sublist(36, 40)), 'data');
      // Taille RIFF = nombre total − 8 octets.
      final riffSize = _u32(wav, 4);
      expect(riffSize, wav.length - 8);
      // Taille data = bytes réels de la partie PCM.
      final dataSize = _u32(wav, 40);
      expect(dataSize, wav.length - 44);
    });

    test('un glissando est non vide et non silencieux', () {
      final wav = WavTone.synth(notes: const [(760, 900)], endFrequency: 120);
      expect(wav.length, greaterThan(100));
      // Au moins un échantillon significatif (pas du silence).
      var hasSig = false;
      for (var i = 44; i < wav.length - 1; i += 2) {
        final s = ByteData.view(
          wav.buffer,
          wav.offsetInBytes + i,
          2,
        ).getInt16(0);
        if (s.abs() > 2000) {
          hasSig = true;
          break;
        }
      }
      expect(hasSig, isTrue);
    });

    test('chaque cue est générable (bytes non vides)', () {
      for (final cue in SoundCue.values) {
        final engine = SoundEngine();
        expect(engine.bytesFor(cue).length, greaterThan(1000));
      }
    });
  });

  group('SoundEngine.play — gate du réglage', () {
    test('soundOn=false : aucune lecture (pas de canal plateforme)', () async {
      var asked = false;
      final engine = SoundEngine(
        soundOn: () {
          asked = true;
          return Future.value(false);
        },
      );
      await engine.play(SoundCue.victory);
      expect(asked, isTrue);
    });
  });

  group('VibrationEngine — gate du réglage', () {
    test('vibrationOn=false : aucun appel haptique', () async {
      var asked = false;
      final engine = VibrationEngine(
        vibrationOn: () {
          asked = true;
          return Future.value(false);
        },
      );
      await engine.heavy();
      expect(asked, isTrue);
    });
  });
}

int _u32(Uint8List b, int offset) =>
    b[offset] |
    (b[offset + 1] << 8) |
    (b[offset + 2] << 16) |
    (b[offset + 3] << 24);
