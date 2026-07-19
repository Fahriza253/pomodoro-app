import 'package:pomodoro_app/domain/common/enums.dart';

/// Local UI state for idle / pre-start (not persisted).
class TimerUiState {
  const TimerUiState({
    this.selectedMode = TimerMode.pomodoro,
    this.selectedTagId,
    this.preStartCountdown,
  });

  final TimerMode selectedMode;
  final String? selectedTagId;
  final int? preStartCountdown;

  bool get isPreStart => preStartCountdown != null;

  TimerUiState copyWith({
    TimerMode? selectedMode,
    String? selectedTagId,
    int? preStartCountdown,
    bool clearPreStart = false,
  }) {
    return TimerUiState(
      selectedMode: selectedMode ?? this.selectedMode,
      selectedTagId: selectedTagId ?? this.selectedTagId,
      preStartCountdown: clearPreStart
          ? null
          : (preStartCountdown ?? this.preStartCountdown),
    );
  }
}
