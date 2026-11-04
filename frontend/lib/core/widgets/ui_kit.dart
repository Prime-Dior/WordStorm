import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

const Color kPanelColor = Color(0xFF152440);

Color categoryColor(String category) {
  const categories = [
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
  const colors = [
    AppColors.yellow,
    AppColors.teal,
    Color(0xFF8962EF),
    AppColors.coral,
  ];
  final index = categories.indexOf(category);
  return colors[(index < 0 ? 0 : index) % colors.length];
}

/// Titre simple, avec un bouton retour facultatif.
class ScreenTitle extends StatelessWidget {
  const ScreenTitle(this.text, {super.key, this.onBack, this.fontSize = 32});

  final String text;
  final VoidCallback? onBack;
  final double fontSize;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      SizedBox(
        width: 48,
        child: onBack == null
            ? null
            : IconButton(
                onPressed: onBack,
                tooltip: 'Retour',
                icon: const Icon(Icons.arrow_back, color: AppColors.offWhite),
              ),
      ),
      Expanded(
        child: Text(
          text.toUpperCase(),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontFamily: AppTheme.displayFont,
            fontSize: fontSize,
            color: AppColors.offWhite,
          ),
        ),
      ),
      const SizedBox(width: 48),
    ],
  );
}

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
    ),
    child: child,
  );
}

class GradientProgressBar extends StatelessWidget {
  const GradientProgressBar({required this.value, super.key, this.height = 8});

  final double value;
  final double height;

  @override
  Widget build(BuildContext context) => LinearProgressIndicator(
    value: value.clamp(0.0, 1.0),
    minHeight: height,
    color: AppColors.teal,
    backgroundColor: const Color(0xFF13263B),
    borderRadius: BorderRadius.circular(8),
  );
}

class HeroImage extends StatelessWidget {
  const HeroImage({super.key, this.width = 110});

  final double width;

  @override
  Widget build(BuildContext context) => Image.asset(
    'assets/images/personnage_w.png',
    width: width,
    fit: BoxFit.contain,
  );
}

class LetterBadge extends StatelessWidget {
  const LetterBadge(this.letter, {super.key, this.size = 30});

  final String letter;
  final double size;

  @override
  Widget build(BuildContext context) => CircleAvatar(
    radius: size / 2,
    backgroundColor: AppColors.yellow,
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
