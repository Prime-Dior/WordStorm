import 'package:flutter/material.dart';

/// Palette officielle de la maquette (`--y`, `--r`, `--t`, `--n`, `--w`, `--g`,
/// `--v` dans le CSS de `wordstorm.html`). Ne pas inventer de couleur ici :
/// chaque teinte a été relevée dans la maquette, cf. `docs/ANALYSE.md` annexe.
@immutable
class AppColors {
  const AppColors._();

  // Couleurs principales de la charte.
  static const Color yellow = Color(0xFFFFB703);
  static const Color coral = Color(0xFFFF5A5F);
  static const Color teal = Color(0xFF2EC4B6);
  static const Color navyBlue = Color(0xFF1E2A44);
  static const Color offWhite = Color(0xFFF4F7FB);
  static const Color blueGray = Color(0xFF8B9BB4);
  static const Color purple = Color(0xFF7B61FF);

  // Verts de validation (coche, badge « OK »).
  static const Color validate = Color(0xFF2FD18A);
  static const Color validateDeep = Color(0xFF1FBF74);
  static const Color validateDark = Color(0xFF128A52);

  // Dégradés d'arrière-plan relevés dans la maquette.
  static const Color bgTop = Color(0xFF26366B);
  static const Color bgBottom = Color(0xFF141D33);
  static const Color pageTop = Color(0xFF2B3D6B);
  static const Color pageBottom = Color(0xFF0E1424);
  static const Color nightSkyTop = Color(0xFF2A3B7A);

  // Ciel de jour (accueil).
  static const Color daySkyTop = Color(0xFF58C4FF);
  static const Color daySkyMiddle = Color(0xFF9FD9FC);
  static const Color daySkyBottom = Color(0xFFFFD9A0);

  // Variantes foncées (ombre pleine sous les boutons extrudés).
  static const Color yellowDark = Color(0xFFC98300);
  static const Color yellowLight = Color(0xFFFFD25A);
  static const Color coralDark = Color(0xFFB93A3E);
  static const Color tealDark = Color(0xFF1C8F85);
  static const Color tealLight = Color(0xFF6FF0E2);
  static const Color purpleDark = Color(0xFF4B3BB8);
  static const Color purpleLight = Color(0xFFA592FF);
  static const Color darkButton = Color(0xFF25355A);
  static const Color darkButtonTop = Color(0xFF3B4D7D);
  static const Color darkButtonDeep = Color(0xFF0E1628);
  static const Color podiumTop = Color(0xFF3F6FD8);
  static const Color podiumBottom = Color(0xFF1F43A0);

  // Tuile de lettre 3D.
  static const Color letterTileTop = Color(0xFFFFE27A);
  static const Color letterTileMiddle = Color(0xFFFFB703);
  static const Color letterTileBottom = Color(0xFFF29A00);
  static const Color letterTileShadow = Color(0xFFA86F00);
  static const Color letterTileInk = Color(0xFF3A2A00);
}
