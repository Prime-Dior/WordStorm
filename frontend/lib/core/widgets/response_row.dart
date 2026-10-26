import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import 'letter_tile.dart';
import 'ui_kit.dart';

/// Ligne de réponse de la maquette (`.rw`) : pastille d'icône de catégorie,
/// libellé, champ de saisie clair, coche verte quand la ligne est remplie.
/// État focus = bordure turquoise + halo (`.rw:focus-within`).
class ResponseRow extends StatefulWidget {
  const ResponseRow({
    required this.category,
    required this.onChanged,
    super.key,
    this.categoryColor,
    this.enabled = true,
    this.turnLocked = false,
    this.controller,
    this.textInputAction = TextInputAction.next,
    this.onSubmitted,
    this.iconName,
    this.alert = false,
  });

  final ValueChanged<String> onChanged;
  final ValueChanged<String>? onSubmitted;
  final String category;
  final Color? categoryColor;
  final bool enabled;
  final bool turnLocked;
  final TextEditingController? controller;
  final TextInputAction textInputAction;

  /// Identifiant du glyphe de catégorie (voir `wordstorm_icons.dart`) ;
  /// sinon le libellé de la catégorie sert d'identifiant.
  final String? iconName;

  /// 10 dernières secondes : bordure corail (maquette 11).
  final bool alert;

  @override
  State<ResponseRow> createState() => _ResponseRowState();
}

class _ResponseRowState extends State<ResponseRow> {
  final FocusNode _focus = FocusNode();
  bool _focused = false;
  bool _hovered = false;
  late final TextEditingController _controller;
  bool _ownsController = false;

  @override
  void initState() {
    super.initState();
    _focus.addListener(() {
      if (mounted) setState(() => _focused = _focus.hasFocus);
    });
    final external = widget.controller;
    if (external == null) {
      _controller = TextEditingController();
      _ownsController = true;
    } else {
      _controller = external;
    }
  }

  @override
  void dispose() {
    _focus.dispose();
    if (_ownsController) _controller.dispose();
    super.dispose();
  }

  // Caractères autorisés à la saisie (cahier §7.4) : lettres, accents,
  // espaces, tirets, apostrophes. Chiffres et ponctuation bloqués en live.
  static final RegExp _notAllowed = RegExp(r"[^\p{L}\s'\-]", unicode: true);

  @override
  Widget build(BuildContext context) {
    final filled = _controller.text.trim().isNotEmpty;
    final border = widget.alert && filled
        ? const Color(0xFFFF8A8E)
        : _focused
        ? AppColors.teal
        : filled
        ? const Color(0xFF2FD18A)
        : _hovered
        ? const Color(0x55FFFFFF)
        : const Color(0x1AFFFFFF);

    final editable = widget.enabled && !widget.turnLocked;
    // Curseur texte sur toute la ligne (un clic place le curseur dans
    // le champ) ; sens interdit quand la manche est verrouillée.
    return MouseRegion(
      cursor: editable
          ? SystemMouseCursors.text
          : SystemMouseCursors.forbidden,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: editable ? _focus.requestFocus : null,
        child: AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xF015243F),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: border, width: 2),
        boxShadow: _focused
            ? [BoxShadow(color: AppColors.teal.withAlpha(0x88), blurRadius: 14)]
            : const [],
      ),
      child: Row(
        children: [
          CategoryBadge(
            iconName: widget.iconName ?? widget.category,
            color: widget.categoryColor ?? categoryColor(widget.category),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 92,
            child: Text(
              widget.category,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.offWhite,
                height: 1.1,
              ),
            ),
          ),
          Expanded(
            child: TextField(
              focusNode: _focus,
              controller: _controller,
              enabled: editable,
              mouseCursor: editable
                  ? SystemMouseCursors.text
                  : SystemMouseCursors.forbidden,
              textCapitalization: TextCapitalization.words,
              autocorrect: false,
              enableSuggestions: false,
              keyboardType: TextInputType.name,
              textInputAction: widget.textInputAction,
              maxLength: 40,
              onChanged: (raw) {
                final cleaned = raw.replaceAll(_notAllowed, '');
                if (cleaned != raw) {
                  _controller
                    ..text = cleaned
                    ..selection = TextSelection.fromPosition(
                      TextPosition(offset: cleaned.length.clamp(0, 40)),
                    );
                }
                widget.onChanged(cleaned);
              },
              onSubmitted: widget.onSubmitted,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.navyBlue,
              ),
              decoration: InputDecoration(
                isDense: true,
                filled: true,
                counterText: '',
                fillColor: const Color(0xFFCADDF3),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 9,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                hintText: 'Votre réponse…',
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppColors.teal, width: 2),
                ),
                hintStyle: TextStyle(
                  color: const Color(0xFF1E2A44).withAlpha(0x88),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          AnimatedOpacity(
            opacity: filled ? 1 : 0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutBack,
            child: AnimatedScale(
              scale: filled ? 1 : 0.4,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutBack,
              child: Container(
                width: 26,
                height: 26,
                decoration: const BoxDecoration(
                  color: Color(0xFF2FD18A),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  size: 18,
                  color: AppColors.navyBlue,
                ),
              ),
            ),
          ),
        ],
      ),
      ),
      ),
    );
  }
}
