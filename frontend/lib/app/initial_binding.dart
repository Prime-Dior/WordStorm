import 'package:get/get.dart';

import '../core/audio/sound_engine.dart';
import '../data/api/api_client.dart';

import '../data/dictionary/asset_dictionary_repository.dart';
import '../data/history/history_repository.dart';

import '../data/repository/auth_repository.dart';
import '../data/repository/room_repository.dart';

import '../data/settings/settings_repository.dart';

import '../presentation/controllers/app_controller.dart';
import '../presentation/controllers/solo_session_controller.dart';

/// Dépendances partagées durant toute la vie de l'application.
class InitialBinding extends Bindings {
  @override
  void dependencies() {
    final apiClient = ApiClient();

    Get.put<ApiClient>(apiClient, permanent: true);

    Get.put<AuthRepository>(AuthRepository(apiClient), permanent: true);

    Get.put<RoomRepository>(RoomRepository(apiClient), permanent: true);

    Get.put<SettingsRepository>(SettingsRepository(), permanent: true);
    Get.put<HistoryRepository>(LocalHistoryRepository(), permanent: true);
    Get.put<AssetDictionaryRepository>(
      AssetDictionaryRepository(),
      permanent: true,
    );
    Get.put<SoundEngine>(
      SoundEngine(soundOn: () => Get.find<SettingsRepository>().soundOn()),
      permanent: true,
    );
    Get.put<VibrationEngine>(
      VibrationEngine(
        vibrationOn: () => Get.find<SettingsRepository>().vibrationOn(),
      ),
      permanent: true,
    );
    Get.put<SoloSessionController>(
      SoloSessionController(
        dictionaryRepository: Get.find<AssetDictionaryRepository>(),
        historyRepository: Get.find<HistoryRepository>(),
      ),
      permanent: true,
    );
    Get.put<AppController>(AppController(), permanent: true);
  }
}
