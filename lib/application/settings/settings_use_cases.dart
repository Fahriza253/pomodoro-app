import 'dart:async';

import 'package:pomodoro_app/data/repositories/settings_repository.dart';
import 'package:pomodoro_app/domain/common/app_error.dart';
import 'package:pomodoro_app/domain/common/result.dart';
import 'package:pomodoro_app/domain/settings/app_settings.dart';
import 'package:pomodoro_app/domain/settings/settings_validator.dart';
import 'package:pomodoro_app/platform/aod/aod_adapter.dart';
import 'package:pomodoro_app/platform/flash/flash_adapter.dart';
import 'package:pomodoro_app/platform/focus/focus_adapter.dart';
import 'package:pomodoro_app/platform/notifications/notification_adapter.dart';

/// UC-07, UC-09 — read/write AppSettings with validation and debounced stat invalidation.
class SettingsUseCases {
  SettingsUseCases({
    required this._settingsRepository,
    required this._focusAdapter,
    required this._notificationAdapter,
    required this._aodAdapter,
    required this._flashAdapter,
    required this._onStatisticInvalidation,
    SettingsValidator? validator,
  }) : _validator = validator ?? const SettingsValidator();

  final SettingsRepository _settingsRepository;
  final FocusAdapter _focusAdapter;
  final NotificationAdapter _notificationAdapter;
  final AODAdapter _aodAdapter;
  final FlashAdapter _flashAdapter;
  final void Function() _onStatisticInvalidation;
  final SettingsValidator _validator;

  Timer? _statDebounce;

  Future<AppSettings> getSettings() => _settingsRepository.get();

  Stream<AppSettings> watchSettings() => _settingsRepository.watch();

  FocusCapabilities getFocusCapabilities() => _focusAdapter.capabilities();

  NotificationCapabilities getNotificationCapabilities() =>
      _notificationAdapter.capabilities();

  AODCapabilities getAodCapabilities() => _aodAdapter.capabilities();

  FlashCapabilities getFlashCapabilities() => _flashAdapter.capabilities();

  Future<AppResult<AppSettings>> updateSettings(AppSettingsPatch patch) async {
    try {
      final current = await _settingsRepository.get();
      final validation = _validator.validatePatch(current, patch);
      if (!validation.isValid) {
        return err(
          ValidationError(
            code: validation.code ?? 'SETTINGS_INVALID',
            message: validation.message ?? 'Invalid settings.',
          ),
        );
      }

      final updated = await _settingsRepository.update(patch);

      if (patch.trackFailedSessions != null) {
        _scheduleStatisticInvalidation();
      }

      return ok(updated);
    } on AppError catch (e) {
      return err(e);
    }
  }

  void _scheduleStatisticInvalidation() {
    _statDebounce?.cancel();
    _statDebounce = Timer(const Duration(milliseconds: 300), () {
      _onStatisticInvalidation();
    });
  }

  void dispose() {
    _statDebounce?.cancel();
  }
}
