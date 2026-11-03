import 'package:flutter/material.dart';

/// Petite case colorée qui affiche une lettre.
class LetterTile extends StatelessWidget {
  const LetterTile({
    required this.letter,
    super.key,
    this.size,
    this.fontSize,
    this.rotation = 0,
    this.done,
    this.topColor,
    this.middleColor,
    this.bottomColor,
    this.shadowColor,
    this.textColor,
  });

  final String letter;
  final double? size;
  final double? fontSize;
  final double rotation;
  final bool? done;
  final Color? topColor;
  final Color? middleColor;
  final Color? bottomColor;
  final Color? shadowColor;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    final side = size ?? 56;
    return Semantics(
      label: 'Lettre ${letter.toUpperCase()}',
      child: Transform.rotate(
        angle: rotation,
        child: Container(
          width: side,
          height: side,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: middleColor ?? const Color(0xFFFFB703),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: shadowColor ?? Colors.transparent),
          ),
          child: Text(
            letter.toUpperCase(),
            style: TextStyle(
              fontSize: fontSize ?? side * 0.52,
              fontWeight: FontWeight.bold,
              color: textColor ?? const Color(0xFF17233A),
            ),
          ),
        ),
      ),
    );
  }
}

/// Petit rond coloré qui contient une icône de catégorie.
class CategoryBadge extends StatelessWidget {
  const CategoryBadge({required this.iconName, this.color, super.key});

  final String iconName;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    IconData icon = Icons.star;
    if (iconName == 'user') icon = Icons.person;
    if (iconName == 'users') icon = Icons.people;
    if (iconName == 'city') icon = Icons.location_city;
    if (iconName == 'globe') icon = Icons.public;
    if (iconName == 'paw') icon = Icons.pets;
    if (iconName == 'ball') icon = Icons.sports_soccer;
    if (iconName == 'film') icon = Icons.movie;
    if (iconName == 'book') icon = Icons.menu_book;

    return CircleAvatar(
      radius: 18,
      backgroundColor: color ?? const Color(0xFFFFB703),
      child: Icon(icon, size: 20, color: const Color(0xFF17233A)),
    );
  }
}
