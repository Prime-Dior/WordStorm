// Driver des tests d'intégration Wordstorm (convention flutter drive) :
// publie les résultats du test cible (`--target=…`) vers le runner.
// Voir integration_test/solo_e2e_test.dart (phase 5, docs/PLAN.md).
library;

import 'package:integration_test/integration_test_driver.dart';

Future<void> main() => integrationDriver();
