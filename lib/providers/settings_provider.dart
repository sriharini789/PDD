import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/settings_model.dart';

class SettingsNotifier extends AsyncNotifier<SettingsModel> {
  @override
  Future<SettingsModel> build() async {
    return SettingsModel(darkMode: false, aiModel: 'gemini-1.5-pro', privacyTelemetry: true);
  }
  
  Future<void> updateSettings(SettingsModel newSettings) async {
    state = const AsyncValue.loading();
    await Future.delayed(const Duration(milliseconds: 500));
    state = AsyncValue.data(newSettings);
  }
}

final settingsProvider = AsyncNotifierProvider<SettingsNotifier, SettingsModel>(() => SettingsNotifier());