/// Normalisation des réponses — Dart pur, portage fidèle de
/// `gameLogic.js` du prototype Petit Bac :
/// insensible à la casse, aux accents (décomposition NFD simulée), espaces
/// de bord supprimés. Les articles et pluriels ne sont PAS corrigés
/// (comportement provisoire, cf. `docs/RESTE_A_FAIRE.md`).
library;

/// Table de translittération accents → lettre de base (équivalent NFD +
/// suppression des diacritiques pour les caractères latins courants,
/// y compris ligatures œ/æ utilisées en français).
const Map<String, String> _accents = {
  'à': 'a',
  'á': 'a',
  'â': 'a',
  'ä': 'a',
  'ã': 'a',
  'å': 'a',
  'è': 'e',
  'é': 'e',
  'ê': 'e',
  'ë': 'e',
  'ì': 'i',
  'í': 'i',
  'î': 'i',
  'ï': 'i',
  'ò': 'o',
  'ó': 'o',
  'ô': 'o',
  'ö': 'o',
  'õ': 'o',
  'ù': 'u',
  'ú': 'u',
  'û': 'u',
  'ü': 'u',
  'ç': 'c',
  'ñ': 'n',
  'ý': 'y',
  'ÿ': 'y',
  'œ': 'oe',
  'æ': 'ae',
  'ß': 'ss',
  'ỳ': 'y',
  'ą': 'a',
  'ę': 'e',
  'ł': 'l',
  'ś': 's',
  'ź': 'z',
  'ż': 'z',
  'ć': 'c',
  'ń': 'n',
  'ā': 'a',
  'ē': 'e',
  'ī': 'i',
  'ō': 'o',
  'ū': 'u',
};

/// Normalise une réponse pour comparaison et stockage :
/// minuscules, accents supprimés, espaces de bord retirés.
String normalizeAnswer(String raw) {
  final s = raw.trim().toLowerCase();
  if (s.isEmpty) return s;
  final out = StringBuffer();
  for (final rune in s.runes) {
    final ch = String.fromCharCode(rune);
    out.write(_accents[ch] ?? ch);
  }
  return out.toString();
}

/// Filtre de saisie en direct (portage de `sanitizeInput`) : ne laisse
/// passer que les lettres (accents inclus), espaces, tirets et apostrophes.
/// Chiffres, ponctuation et symboles sont supprimés.
String sanitizeInput(String text) =>
    text.replaceAll(RegExp(r"[^\p{L}\s'\-]", unicode: true), '');

/// La réponse commence-t-elle par la lettre tirée ? (insensible à la
/// casse/accents, portage de `firstLetterMatches`).
bool startsWithLetter(String answer, String letter) {
  final n = normalizeAnswer(answer);
  if (n.isEmpty) return false;
  return n[0] == normalizeAnswer(letter);
}
