import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pomodoro_app/app/providers.dart';
import 'package:pomodoro_app/app/timer_providers.dart';
import 'package:pomodoro_app/application/settings/settings_use_cases.dart';
import 'package:pomodoro_app/domain/settings/app_settings.dart';
import 'package:pomodoro_app/presentation/statistic/statistic_providers.dart';

final settingsUseCasesProvider = Provider<SettingsUseCases>((ref) {
  final useCases = SettingsUseCases(
    settingsRepository: ref.watch(settingsRepositoryProvider),
    focusAdapter: ref.watch(focusAdapterProvider),
    notificationAdapter: ref.watch(notificationAdapterProvider),
    aodAdapter: ref.watch(aodAdapterProvider),
    flashAdapter: ref.watch(flashAdapterProvider),
    onStatisticInvalidation: () {
      ref.read(statisticRefreshTokenProvider.notifier).state++;
    },
  );
  ref.onDispose(useCases.dispose);
  return useCases;
});

final appSettingsStreamProvider = StreamProvider<AppSettings>((ref) {
  return ref.watch(settingsUseCasesProvider).watchSettings();
});

final focusCapabilitiesProvider = Provider((ref) {
  return ref.watch(settingsUseCasesProvider).getFocusCapabilities();
});

final aodCapabilitiesProvider = Provider((ref) {
  return ref.watch(settingsUseCasesProvider).getAodCapabilities();
});

final flashCapabilitiesProvider = Provider((ref) {
  return ref.watch(settingsUseCasesProvider).getFlashCapabilities();
});
