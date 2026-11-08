import 'package:pomodoro_app/domain/common/enums.dart';

/// Local UI state for idle tag/mode selection (not persisted).
class TimerUiState {
  const TimerUiState({
    this.selectedMode = TimerMode.pomodoro,
    this.selectedTagId,
  });

  final TimerMode selectedMode;
  final String? selectedTagId;

  TimerUiState copyWith({
    TimerMode? selectedMode,
    String? selectedTagId,
  }) {
    return TimerUiState(
      selectedMode: selectedMode ?? this.selectedMode,
      selectedTagId: selectedTagId ?? this.selectedTagId,
    );
  }
}
