import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/arcade_button.dart';
import '../../../core/widgets/code_field.dart';
import '../../../core/widgets/icons/wordstorm_icons.dart';
import '../../../core/widgets/screen_scaffold.dart';
import '../../../core/widgets/wordstorm_logo.dart';
import '../../controllers/menu_controller.dart' as menu_controller;

/// Menu principal : choix du mode de jeu ou accès aux autres pages.
class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  late final menu_controller.MenuController _controller =
      Get.find<menu_controller.MenuController>();

  @override
  Widget build(BuildContext context) {
    return ScreenScaffold(
      skylineHeight: 360,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Logo et accès aux réglages.
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const WordstormLogoSmall(showLightning: true),
              _IconButton(
                tooltip: 'Paramètres',
                onPressed: _controller.openSettings,
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Petit message sous le logo.
          const Row(
            children: [
              // Avatar de la maquette ; personnalisation à la phase 6.
              CircleAvatar(
                radius: 16,
                backgroundImage: AssetImage('assets/images/avatar_toi.png'),
              ),
              SizedBox(width: 10),
              Text(
                'Salut, champion !',
                style: TextStyle(
                  fontFamily: AppTheme.bodyFont,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: AppColors.offWhite,
                ),
              ),
            ],
          ),
          const Spacer(),

          // Le mode solo ouvre les réglages de la partie.
          ArcadeMenuCard(
            label: 'Solo',
            detail: 'Joue à ton rythme',
            variant: ArcadeButtonVariant.yellow,
            iconGlyph: 'user',
            onPressed: _controller.openSolo,
          ),
          const SizedBox(height: 12),

          // Le mode multijoueur passe aussi par la configuration.
          ArcadeMenuCard(
            label: 'Multijoueur',
            detail: 'Crée un salon',
            variant: ArcadeButtonVariant.teal,
            iconGlyph: 'users',
            onPressed: _controller.openMultiplayer,
          ),
          const SizedBox(height: 14),

          // Champ de code comme sur la maquette.
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Rejoindre avec un code',
                style: TextStyle(
                  fontFamily: AppTheme.bodyFont,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.7,
                  color: AppColors.offWhite,
                ),
              ),
              const SizedBox(height: 8),
              CodeField(
                controller: _controller.codeController,
                onValidated: _controller.join,
                trailing: ArcadeButton(
                  label: 'OK',
                  small: true,
                  onPressed: _controller.join,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Historique des parties et meilleurs scores.
          ArcadeMenuCard(
            label: 'Classement',
            detail: 'Historique & records',
            detailIsStub: true,
            variant: ArcadeButtonVariant.dark,
            iconGlyph: 'trophy',
            labelColor: AppColors.yellow,
            onPressed: _controller.openHistory,
          ),
          const Spacer(),
        ],
      ),
    );
  }
}

/// Carte de menu volumineuse (`.b.mc`) : pastille icône + libellé + détail +
/// flèche. La variante teal avance sa teinte en dégradé comme en maquette.
class ArcadeMenuCard extends StatelessWidget {
  const ArcadeMenuCard({
    required this.label,
    required this.detail,
    required this.variant,
    required this.iconGlyph,
    super.key,
    this.detailIsStub = false,
    this.labelColor,
    this.onPressed,
  });

  final String label;
  final String detail;
  final ArcadeButtonVariant variant;
  final String iconGlyph;

  /// `true` : le détail correspond à un horaire non branché (masqué).
  final bool detailIsStub;
  final Color? labelColor;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: ButtonStyle(
        padding: const WidgetStatePropertyAll(EdgeInsets.zero),
        mouseCursor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.disabled)
              ? SystemMouseCursors.basic
              : SystemMouseCursors.click,
        ),
      ),
      child: Ink(
        height: 70,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: switch (variant) {
            ArcadeButtonVariant.yellow => const LinearGradient(
              colors: [AppColors.yellowLight, AppColors.yellow],
            ),
            ArcadeButtonVariant.teal => const LinearGradient(
              colors: [AppColors.tealLight, AppColors.teal],
            ),
            _ => const LinearGradient(
              colors: [AppColors.darkButtonTop, AppColors.darkButton],
            ),
          },
        ),
        child: Row(
          children: [
            const SizedBox(width: 14),
            Container(
              width: 50,
              height: 50,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.navyBlue,
                boxShadow: [
                  BoxShadow(color: Color(0x66000000), offset: Offset(0, 3)),
                ],
              ),
              alignment: Alignment.center,
              child: switch (iconGlyph) {
                'users' => WordstormIcons.users(size: 26, color: Colors.white),
                'trophy' => WordstormIcons.trophy(
                  size: 26,
                  color: labelColor ?? Colors.white,
                ),
                _ => WordstormIcons.user(size: 26, color: Colors.white),
              },
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label.toUpperCase(),
                    style: TextStyle(
                      fontFamily: AppTheme.displayFont,
                      fontSize: 25,
                      height: 1,
                      color:
                          labelColor ??
                          (variant == ArcadeButtonVariant.yellow
                              ? AppColors.navyBlue
                              : Colors.white),
                    ),
                  ),
                  Text(
                    detail,
                    style: TextStyle(
                      fontFamily: AppTheme.bodyFont,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      color:
                          (variant == ArcadeButtonVariant.dark
                                  ? Colors.white
                                  : AppColors.navyBlue)
                              .withAlpha(0xCC),
                    ),
                  ),
                ],
              ),
            ),
            WordstormIcons.arrow(color: Colors.white),
            const SizedBox(width: 14),
          ],
        ),
      ),
    );
  }
}

class _IconButton extends StatelessWidget {
  const _IconButton({required this.tooltip, required this.onPressed});

  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Tooltip(
    message: tooltip,
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        mouseCursor: SystemMouseCursors.click,
        child: Ink(
          width: 42,
          height: 42,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.darkButton,
            boxShadow: [
              BoxShadow(color: AppColors.darkButtonDeep, offset: Offset(0, 4)),
            ],
          ),
          child: const Icon(
            Icons.settings_outlined,
            size: 22,
            color: AppColors.blueGray,
          ),
        ),
      ),
    ),
  );
}
