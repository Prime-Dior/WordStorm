import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/salon_code.dart';
import '../../core/widgets/arcade_button.dart';
import '../../core/widgets/code_field.dart';
import '../../core/widgets/icons/wordstorm_icons.dart';
import '../../core/widgets/pressable.dart';
import '../../core/widgets/screen_scaffold.dart';
import '../../core/widgets/ui_kit.dart';
import '../../core/widgets/wordstorm_logo.dart';
import '../join/join_screen.dart';

/// Menu principal (maquette 02) : Solo, Multijoueur, rejoindre un salon
/// avec un code, Classement ; engrenage des paramètres en haut à droite.
class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  final TextEditingController _codeController = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  /// « OK » : champ vide → écran « Rejoindre un salon » ; code mal formé
  /// → message sous le champ ; sinon on cherche le salon.
  void _join() {
    final code = SalonCode.normalized(_codeController.text);
    if (code.isEmpty) {
      context.push('/join');
      return;
    }
    if (!SalonCode.isWellFormed(code)) {
      setState(() => _error = 'Code : 6 lettres ou chiffres (sans 0, O, 1, I).');
      return;
    }
    setState(() => _error = null);
    openSalonByCode(context, code);
  }

  @override
  Widget build(BuildContext context) {
    return ScreenScaffold(
      skylineHeight: 360,
      child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 8),
                  // Logo et accès aux réglages.
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(left: 4),
                        child: WordstormLogoSmall(showLightning: true),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 14),
                        child: RoundIconButton(
                          tooltip: 'Paramètres',
                          icon: WordstormIcons.gear(
                            size: 22,
                            color: AppColors.offWhite,
                          ),
                          onPressed: () => context.push('/settings'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: _GreetingPill(),
                  ),
                  Expanded(
                    child: Align(
                      alignment: const Alignment(0, .35),
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                  ArcadeMenuCard(
                    label: 'Solo',
                    detail: 'Joue à ton rythme',
                    variant: ArcadeButtonVariant.yellow,
                    iconGlyph: 'user',
                    onPressed: () => context.push('/config?mode=solo'),
                  ),
                  const SizedBox(height: 14),
                  ArcadeMenuCard(
                    label: 'Multijoueur',
                    detail: 'Crée un salon',
                    variant: ArcadeButtonVariant.teal,
                    iconGlyph: 'users',
                    onPressed: () => context.push('/config?mode=multi'),
                  ),
                  const SizedBox(height: 14),

                  // Bloc « Rejoindre avec un code ».
                  Container(
                    padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                    decoration: BoxDecoration(
                      color: const Color(0xF0142038),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'REJOINDRE AVEC UN CODE',
                          style: TextStyle(
                            fontFamily: AppTheme.bodyFont,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: .4,
                            color: AppColors.offWhite,
                          ),
                        ),
                        const SizedBox(height: 10),
                        CodeField(
                          controller: _codeController,
                          errorText: _error,
                          onValidated: _join,
                          trailing: SizedBox(
                            width: 48,
                            child: ArcadeButton(
                              label: 'OK',
                              small: true,
                              padding: EdgeInsets.zero,
                              minHeight: 44,
                              tooltip: 'Rejoindre le salon',
                              onPressed: _join,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  ArcadeMenuCard(
                    label: 'Classement',
                    detail: 'Les meilleurs joueurs',
                    variant: ArcadeButtonVariant.dark,
                    iconGlyph: 'trophy',
                    onPressed: () => context.push('/history'),
                  ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
    );
  }
}

/// Pastille « Salut, champion ! » avec l'avatar du joueur.
class _GreetingPill extends StatelessWidget {
  const _GreetingPill();

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(4, 4, 14, 4),
    decoration: BoxDecoration(
      color: const Color(0xE6152440),
      borderRadius: BorderRadius.circular(12),
    ),
    child: const Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        PlayerAvatar(
          asset: 'assets/images/avatar_toi.png',
          size: 30,
          ringWidth: 2,
        ),
        SizedBox(width: 8),
        Text(
          'Salut, champion !',
          style: TextStyle(
            fontFamily: AppTheme.bodyFont,
            fontWeight: FontWeight.w700,
            fontSize: 12,
            color: AppColors.offWhite,
          ),
        ),
      ],
    ),
  );
}

/// Grande carte de menu (`.b.mc`) : pastille icône + titre + détail +
/// flèche, tranche 3D en bas. Survol : la carte se soulève et s'éclaire ;
/// focus clavier : anneau clair.
class ArcadeMenuCard extends StatelessWidget {
  const ArcadeMenuCard({
    required this.label,
    required this.detail,
    required this.variant,
    required this.iconGlyph,
    super.key,
    this.onPressed,
  });

  final String label;
  final String detail;
  final ArcadeButtonVariant variant;
  final String iconGlyph;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final dark = variant == ArcadeButtonVariant.dark;
    final (light, base, deep) = ArcadeButton.faces(variant);
    final titleColor = dark ? AppColors.offWhite : AppColors.navyBlue;
    final detailColor = dark
        ? AppColors.offWhite.withAlpha(0xB3)
        : AppColors.navyBlue.withAlpha(0xCC);

    return Pressable(
      onPressed: onPressed,
      semanticLabel: '$label. $detail',
      borderRadius: BorderRadius.circular(18),
      builder: (context, state) => AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        transform: Matrix4.translationValues(0, state.pressed ? 4 : 0, 0),
        height: 72,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: dark
              ? Border.all(color: const Color(0x40FFFFFF), width: 1.5)
              : null,
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: state.highlighted
                ? [Color.lerp(light, Colors.white, .15)!, light]
                : [light, base],
          ),
          boxShadow: [
            BoxShadow(
              color: deep,
              offset: Offset(0, state.pressed ? 1 : (state.highlighted ? 7 : 5)),
            ),
            const BoxShadow(
              color: Color(0x55000000),
              offset: Offset(0, 10),
              blurRadius: 14,
            ),
            if (state.highlighted)
              BoxShadow(color: base.withAlpha(0x66), blurRadius: 18),
          ],
        ),
        child: Row(
          children: [
            const SizedBox(width: 14),
            Container(
              width: 46,
              height: 46,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.navyBlue,
              ),
              alignment: Alignment.center,
              child: switch (iconGlyph) {
                'users' => WordstormIcons.users(size: 22, color: Colors.white),
                'trophy' => WordstormIcons.trophy(
                  size: 22,
                  color: AppColors.yellow,
                ),
                _ => WordstormIcons.user(size: 22, color: Colors.white),
              },
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label.toUpperCase(),
                    style: TextStyle(
                      fontFamily: AppTheme.displayFont,
                      fontSize: 27,
                      height: 1.05,
                      color: titleColor,
                    ),
                  ),
                  Text(
                    detail,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: AppTheme.bodyFont,
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                      color: detailColor,
                    ),
                  ),
                ],
              ),
            ),
            if (!dark)
              AnimatedSlide(
                duration: const Duration(milliseconds: 140),
                offset: Offset(state.highlighted ? .25 : 0, 0),
                child: WordstormIcons.arrow(size: 22, color: AppColors.navyBlue),
              ),
            const SizedBox(width: 16),
          ],
        ),
      ),
    );
  }
}
