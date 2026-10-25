import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import 'icons/wordstorm_icons.dart';

/// Ligne de joueur du salon (`.pl` de la maquette) : avatar, pseudo,
/// couronne pour l'hôte, place libre en pointillés pulsée.
class PlayerCard extends StatelessWidget {
  const PlayerCard({
    super.key,
    required this.name,
    required this.host,
    required this.avatar,
    this.emptySlot = false,
  });

  final String name;
  final bool host;

  /// Chemin d'asset de l'avatar, ex. `assets/images/avatar_toi.png`.
  final String? avatar;

  /// Variante « Place libre » : fond transparent bordé de tirets animés.
  final bool emptySlot;

  @override
  Widget build(BuildContext context) {
    if (emptySlot) {
      return Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0x30FFFFFF), width: 2),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0x40FFFFFF), width: 2),
              ),
              alignment: Alignment.center,
              child: WordstormIcons.users(size: 20, color: AppColors.blueGray),
            ),
            const SizedBox(width: 10),
            const Text(
              'Place libre',
              style: TextStyle(
                fontFamily: AppTheme.bodyFont,
                fontWeight: FontWeight.w600,
                fontSize: 15,
                color: AppColors.blueGray,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0x14FFFFFF),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(40),
            child: avatar == null
                ? Container(
                    width: 40,
                    height: 40,
                    color: AppColors.navyBlue,
                    alignment: Alignment.center,
                    child: Text(
                      name.substring(0, 1).toUpperCase(),
                      style: const TextStyle(
                        fontFamily: AppTheme.displayFont,
                        fontSize: 20,
                        color: AppColors.yellow,
                      ),
                    ),
                  )
                : Image.asset(
                    avatar!,
                    width: 40,
                    height: 40,
                    fit: BoxFit.cover,
                  ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: AppTheme.bodyFont,
                fontWeight: FontWeight.w600,
                fontSize: 15,
                color: AppColors.offWhite,
              ),
            ),
          ),
          if (host) WordstormIcons.crown(size: 22, color: AppColors.yellow),
        ],
      ),
    );
  }
}
