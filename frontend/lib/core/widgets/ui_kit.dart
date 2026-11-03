import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import 'icons/wordstorm_icons.dart';
import 'pressable.dart';

/// Petits composants visuels partagés par les écrans (relevés de la
/// maquette Figma) : titres, panneaux, onglets, pastilles, avatars…

/// Fond des panneaux sombres (code du salon, cartes de score).
const Color kPanelColor = Color(0xFF152440);

/// Fond des lignes « vitrées » (catégories, joueurs).
const Color kGlassRowColor = Color(0x1FFFFFFF);

/// Couleur des petits libellés de section (« Mode de jeu »…).
const Color kLabelColor = Color(0xFFA7B6CC);

/// Couleur de la pastille d'une catégorie, dans l'ordre de la maquette :
/// jaune, turquoise, violet, corail, puis on recommence
/// (Prénom jaune, Ville turquoise, Pays violet, Animal corail…).
Color categoryColor(String category) {
  const palette = [
    AppColors.yellow,
    AppColors.teal,
    Color(0xFF8962EF),
    AppColors.coral,
  ];
  const order = [
    'Prénom',
    'Ville',
    'Pays',
    'Animal',
    'Objet',
    'Fleuve',
    'Plante',
    'Métier',
    'Nourriture',
    'Film',
    'Sport',
    'Partie du corps',
    'Marque de voiture',
    'Groupe de musique',
    'Personnage de conte',
    'Matière scolaire',
    'Fruit',
    'Légume',
    'Maladie',
    'Chanson',
  ];
  final index = order.indexOf(category);
  return palette[(index < 0 ? 0 : index) % palette.length];
}

/// Titre d'écran en Bangers (« NOUVELLE PARTIE », « SALON »…), centré,
/// avec une flèche de retour facultative à gauche.
class ScreenTitle extends StatelessWidget {
  const ScreenTitle(this.text, {super.key, this.onBack, this.fontSize = 32});

  final String text;
  final VoidCallback? onBack;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final title = Text(
      text.toUpperCase(),
      textAlign: TextAlign.center,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontFamily: AppTheme.displayFont,
        fontSize: fontSize,
        letterSpacing: .5,
        color: AppColors.offWhite,
        shadows: const [Shadow(color: Color(0xFF0C1429), offset: Offset(0, 3))],
      ),
    );
    return SizedBox(
      height: 56,
      child: Row(
        children: [
          SizedBox(
            width: 44,
            child: onBack == null ? null : BackArrowButton(onPressed: onBack!),
          ),
          Expanded(child: title),
          const SizedBox(width: 44),
        ],
      ),
    );
  }
}

/// Flèche de retour discrète (en haut à gauche des écrans).
class BackArrowButton extends StatelessWidget {
  const BackArrowButton({required this.onPressed, super.key});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Pressable(
    onPressed: onPressed,
    semanticLabel: 'Retour',
    tooltip: 'Retour',
    borderRadius: BorderRadius.circular(22),
    builder: (context, state) => AnimatedContainer(
      duration: const Duration(milliseconds: 140),
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: state.highlighted
            ? const Color(0x33FFFFFF)
            : const Color(0x14FFFFFF),
      ),
      alignment: Alignment.center,
      child: RotatedBox(
        quarterTurns: 2,
        child: WordstormIcons.arrow(size: 20, color: AppColors.offWhite),
      ),
    ),
  );
}

/// Bouton rond sombre à icône (engrenage des paramètres).
class RoundIconButton extends StatelessWidget {
  const RoundIconButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    super.key,
    this.size = 46,
  });

  final Widget icon;
  final String tooltip;
  final VoidCallback onPressed;
  final double size;

  @override
  Widget build(BuildContext context) => Pressable(
    onPressed: onPressed,
    tooltip: tooltip,
    semanticLabel: tooltip,
    borderRadius: BorderRadius.circular(14),
    builder: (context, state) => AnimatedContainer(
      duration: const Duration(milliseconds: 140),
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: state.highlighted
              ? const [Color(0xFF4A5E93), AppColors.darkButtonTop]
              : const [AppColors.darkButtonTop, AppColors.darkButton],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.darkButtonDeep,
            offset: Offset(0, state.pressed ? 1 : 4),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: icon,
    ),
  );
}

/// Petit libellé de section (« Mode de jeu », « Catégories »…).
class FieldLabel extends StatelessWidget {
  const FieldLabel(this.text, {super.key, this.color = kLabelColor});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: TextStyle(
      fontFamily: AppTheme.bodyFont,
      fontSize: 13,
      fontWeight: FontWeight.w600,
      color: color,
    ),
  );
}

/// Pastille d'information arrondie (« 9 catégories », « 6 / 12 »).
class InfoPill extends StatelessWidget {
  const InfoPill(this.text, {super.key, this.color = const Color(0x26FFFFFF)});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(999),
    ),
    child: Text(
      text,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(
        fontFamily: AppTheme.bodyFont,
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: AppColors.offWhite,
      ),
    ),
  );
}

/// Étiquette de catégorie du salon (« Prénom », « Ville »…).
class CategoryChip extends StatelessWidget {
  const CategoryChip(this.label, {super.key});

  final String label;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(
      color: const Color(0x33FFFFFF),
      borderRadius: BorderRadius.circular(999),
    ),
    child: Text(
      label,
      style: const TextStyle(
        fontFamily: AppTheme.bodyFont,
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: AppColors.offWhite,
      ),
    ),
  );
}

/// Panneau sombre arrondi (code d'invitation, cartes de score).
class DarkPanel extends StatelessWidget {
  const DarkPanel({
    required this.child,
    super.key,
    this.padding = const EdgeInsets.all(14),
    this.radius = 16,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;

  @override
  Widget build(BuildContext context) => Container(
    padding: padding,
    decoration: BoxDecoration(
      color: kPanelColor,
      borderRadius: BorderRadius.circular(radius),
      boxShadow: const [
        BoxShadow(
          color: Color(0x55000000),
          offset: Offset(0, 6),
          blurRadius: 14,
        ),
      ],
    ),
    child: child,
  );
}

/// Onglets à deux choix (« Solo | Multijoueur », « Aléatoire |
/// Personnalisé ») : piste sombre, choix actif en pastille jaune.
class SegmentedChoice<T> extends StatelessWidget {
  const SegmentedChoice({
    required this.options,
    required this.value,
    required this.onChanged,
    super.key,
  });

  /// Valeur → libellé affiché.
  final Map<T, String> options;
  final T value;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(3),
    decoration: BoxDecoration(
      color: const Color(0xB3081A2A),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      children: [
        for (final entry in options.entries)
          Expanded(
            child: _SegmentOption(
              label: entry.value,
              selected: entry.key == value,
              onPressed: () => onChanged(entry.key),
            ),
          ),
      ],
    ),
  );
}

class _SegmentOption extends StatelessWidget {
  const _SegmentOption({
    required this.label,
    required this.selected,
    required this.onPressed,
  });

  final String label;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Pressable(
    onPressed: onPressed,
    selected: selected,
    semanticLabel: label,
    liftOnHover: !selected,
    borderRadius: BorderRadius.circular(10),
    builder: (context, state) => AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      height: 38,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        gradient: selected
            ? const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [AppColors.yellowLight, AppColors.yellow],
              )
            : null,
        color: selected
            ? null
            : state.highlighted
            ? const Color(0x1FFFFFFF)
            : const Color(0x00FFFFFF),
        boxShadow: selected
            ? const [
                BoxShadow(color: AppColors.yellowDark, offset: Offset(0, 3)),
              ]
            : const [],
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: AppTheme.bodyFont,
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: selected
              ? AppColors.navyBlue
              : AppColors.offWhite.withAlpha(state.highlighted ? 0xFF : 0xB3),
        ),
      ),
    ),
  );
}

/// Avatar rond cerclé de jaune (joueurs, en-tête de manche).
class PlayerAvatar extends StatelessWidget {
  const PlayerAvatar({
    required this.asset,
    super.key,
    this.size = 40,
    this.ringColor = AppColors.yellow,
    this.ringWidth = 2.5,
  });

  final String asset;
  final double size;
  final Color ringColor;
  final double ringWidth;

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    padding: EdgeInsets.all(ringWidth),
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: ringColor,
      boxShadow: const [
        BoxShadow(color: Color(0x55000000), offset: Offset(0, 3)),
      ],
    ),
    child: ClipOval(child: Image.asset(asset, fit: BoxFit.cover)),
  );
}

/// Barre de progression en dégradé turquoise → jaune
/// (réponses remplies, réponses enregistrées).
class GradientProgressBar extends StatelessWidget {
  const GradientProgressBar({required this.value, super.key, this.height = 8});

  /// Entre 0 et 1.
  final double value;
  final double height;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final v = value.clamp(0.0, 1.0);
      return Container(
        height: height,
        decoration: BoxDecoration(
          color: const Color(0xFF13263B),
          borderRadius: BorderRadius.circular(999),
        ),
        alignment: Alignment.centerLeft,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          width: constraints.maxWidth * v,
          height: height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            gradient: const LinearGradient(
              colors: [AppColors.teal, AppColors.yellow],
            ),
          ),
        ),
      );
    },
  );
}

/// Cadre en pointillés (« Place libre », « + 4 catégories tirées au
/// sort au lancement »).
class DashedBox extends StatelessWidget {
  const DashedBox({
    required this.child,
    super.key,
    this.color = const Color(0x4DFFFFFF),
    this.radius = 12,
    this.padding = const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
  });

  final Widget child;
  final Color color;
  final double radius;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) => CustomPaint(
    painter: _DashedRRectPainter(color: color, radius: radius),
    child: Padding(padding: padding, child: child),
  );
}

class _DashedRRectPainter extends CustomPainter {
  _DashedRRectPainter({required this.color, required this.radius});

  final Color color;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    final rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(radius),
    ).deflate(1);
    final path = Path()..addRRect(rrect);
    const dash = 6.0;
    const gap = 5.0;
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final end = math.min(distance + dash, metric.length);
        canvas.drawPath(metric.extractPath(distance, end), paint);
        distance = end + gap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedRRectPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.radius != radius;
}

/// Case à cocher jaune de la maquette (cochée : fond jaune + coche).
class YellowCheckBox extends StatelessWidget {
  const YellowCheckBox({required this.checked, super.key, this.size = 22});

  final bool checked;
  final double size;

  @override
  Widget build(BuildContext context) => AnimatedContainer(
    duration: const Duration(milliseconds: 140),
    width: size,
    height: size,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: checked ? AppColors.yellow : const Color(0x00FFFFFF),
      borderRadius: BorderRadius.circular(6),
      border: Border.all(
        color: checked ? AppColors.yellow : AppColors.blueGray,
        width: 2,
      ),
    ),
    child: checked
        ? Icon(Icons.check, size: size * .72, color: AppColors.navyBlue)
        : null,
  );
}

/// Ligne cliquable « case + texte » (paramètres, lettres difficiles).
class CheckOptionRow extends StatelessWidget {
  const CheckOptionRow({
    required this.label,
    required this.value,
    required this.onChanged,
    super.key,
    this.glass = true,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  /// Fond vitré (paramètres) ou transparent (configuration).
  final bool glass;

  @override
  Widget build(BuildContext context) => Semantics(
    checked: value,
    child: Pressable(
      onPressed: () => onChanged(!value),
      semanticLabel: label,
      borderRadius: BorderRadius.circular(10),
      liftOnHover: false,
      builder: (context, state) => AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: glass
              ? (state.highlighted
                    ? const Color(0x4D5A6C8C)
                    : const Color(0x33FFFFFF))
              : (state.highlighted
                    ? const Color(0x14FFFFFF)
                    : const Color(0x00FFFFFF)),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            YellowCheckBox(checked: value),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontFamily: AppTheme.bodyFont,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.offWhite,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

/// Image du héros (personnage sur sa tuile « W »).
class HeroImage extends StatelessWidget {
  const HeroImage({super.key, this.width = 110});

  final double width;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: Image.asset(
      'assets/images/personnage_w.png',
      width: width,
      fit: BoxFit.contain,
    ),
  );
}

/// Pastille ronde jaune portant une lettre (récapitulatif des manches).
class LetterBadge extends StatelessWidget {
  const LetterBadge(this.letter, {super.key, this.size = 30});

  final String letter;
  final double size;

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    alignment: Alignment.center,
    decoration: const BoxDecoration(
      shape: BoxShape.circle,
      color: AppColors.yellow,
      boxShadow: [BoxShadow(color: AppColors.yellowDark, offset: Offset(0, 2))],
    ),
    child: Text(
      letter,
      style: TextStyle(
        fontFamily: AppTheme.displayFont,
        fontSize: size * .62,
        color: AppColors.navyBlue,
      ),
    ),
  );
}
