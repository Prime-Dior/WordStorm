import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../core/routes/app_pages.dart';
import '../core/routes/app_routes.dart';
import '../core/theme/app_theme.dart';
import '../presentation/controllers/app_controller.dart';
import 'initial_binding.dart';

/// Racine GetX : configuration des routes, du thème et des dépendances.
class WordstormApp extends StatelessWidget {
  const WordstormApp({super.key});

  @override
  Widget build(BuildContext context) => GetMaterialApp(
    title: 'Wordstorm',
    debugShowCheckedModeBanner: false,
    theme: AppTheme.theme,
    initialRoute: AppRoutes.home,
    getPages: AppPages.pages,
    initialBinding: InitialBinding(),
    defaultTransition: Transition.fadeIn,
    builder: (context, child) {
      final mediaQuery = MediaQuery.of(context);
      final appController = Get.find<AppController>();
      return Obx(
        () => MediaQuery(
          data: mediaQuery.copyWith(
            disableAnimations:
                mediaQuery.disableAnimations ||
                appController.reduceAnimations.value,
          ),
          child: ColoredBox(
            color: const Color(0xFF151925),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 430),
                child: child ?? const SizedBox.shrink(),
              ),
            ),
          ),
        ),
      );
    },
  );
}
