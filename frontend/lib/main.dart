import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/showcase_app.dart';

// Le ProviderScope est nécessaire aux écrans de configuration et au salon.
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(ProviderScope(child: ShowcaseApp()));
}
