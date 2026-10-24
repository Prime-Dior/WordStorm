import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app/app.dart';
import 'core/theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Orientation portrait (prompt §8 — zones de sécurité, encoche).
  SystemChrome.setPreferredOrientations(AppTheme.orientations);
  runApp(const WordstormApp());
}
