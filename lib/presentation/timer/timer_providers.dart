import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pomodoro_app/app/providers.dart';
import 'package:pomodoro_app/app/timer_providers.dart';
import 'package:pomodoro_app/application/timer/timer_coordinator.dart';
import 'package:pomodoro_app/application/timer/timer_view_state.dart';
import 'package:pomodoro_app/domain/common/enums.dart';
import 'package:pomodoro_app/domain/tag/tag_mode_config.dart';
import 'package:pomodoro_app/presentation/tag/tag_providers.dart';
import 'package:pomodoro_app/presentation/timer/timer_ui_state.dart';

final timerViewStateProvider = StreamProvider<TimerViewState>((ref) {
  final coordinator = ref.watch(timerCoordinatorProvider);
  return _seededViewStateStream(coordinator);
});

Stream<TimerViewState> _seededViewStateStream(
  TimerCoordinator coordinator,
) async* {
  yield coordinator.currentViewState;
  yield* coordinator.viewState;
}

/// Emits only when [TimerCoordinator.hasActiveSession] flips (nav badge).
final hasActiveSessionProvider = StreamProvider<bool>((ref) async* {
  final coordinator = ref.watch(timerCoordinatorProvider);
  var last = coordinator.hasActiveSession;
  yield last;
  await for (final _ in coordinator.viewState) {
    final next = coordinator.hasActiveSession;
    if (next != last) {
      last = next;
      yield next;
    }
  }
});

/// Phase/session chrome — skips per-second [displaySec] / grace ticks.
final timerChromeProvider = StreamProvider<TimerViewState>((ref) async* {
  final coordinator = ref.watch(timerCoordinatorProvider);
  var last = coordinator.currentViewState;
  yield last;
  await for (final next in coordinator.viewState) {
    if (!_sameChrome(last, next)) {
      last = next;
      yield next;
    }
  }
});

bool _sameChrome(TimerViewState a, TimerViewState b) =>
    a.phase == b.phase &&
    a.mode == b.mode &&
    a.tagId == b.tagId &&
    a.tagName == b.tagName &&
    a.sessionId == b.sessionId &&
    a.isCountdown == b.isCountdown &&
    a.currentSegmentType == b.currentSegmentType &&
    a.completedFocusCount == b.completedFocusCount &&
    a.totalFocusInCycle == b.totalFocusInCycle &&
    a.completedCycleCount == b.completedCycleCount &&
    a.totalCycleTarget == b.totalCycleTarget &&
    a.showRecoveryPrompt == b.showRecoveryPrompt &&
    a.currentPlannedSec == b.currentPlannedSec &&
    a.segmentEndFinishedType == b.segmentEndFinishedType &&
    a.segmentEndNextType == b.segmentEndNextType &&
    a.segmentEndCompletedCount == b.segmentEndCompletedCount &&
    a.segmentEndTotalCount == b.segmentEndTotalCount;

class TimerUiNotifier extends Notifier<TimerUiState> {
  @override
  TimerUiState build() => const TimerUiState();

  void setMode(TimerMode mode) {
    state = state.copyWith(selectedMode: mode);
  }

  void setTag(String tagId) {
    state = state.copyWith(selectedTagId: tagId);
  }

  void startPreStartCountdown() {
    state = state.copyWith(preStartCountdown: 3);
  }

  void tickPreStart() {
    final current = state.preStartCountdown;
    if (current == null || current <= 0) {
      return;
    }
    if (current == 1) {
      state = state.copyWith(preStartCountdown: 0);
    } else {
      state = state.copyWith(preStartCountdown: current - 1);
    }
  }

  /// Keeps pre-start UI visible while the session is being created.
  void markPreStartLaunching() {
    if (state.preStartCountdown == null) {
      return;
    }
    state = state.copyWith(preStartCountdown: 0);
  }

  void clearPreStart() {
    state = state.copyWith(clearPreStart: true);
  }
}

final timerUiProvider = NotifierProvider<TimerUiNotifier, TimerUiState>(
  TimerUiNotifier.new,
);

/// Tag mode config for idle preview (focus duration, reminder, etc.).
final selectedTagConfigProvider = FutureProvider<TagModeConfig?>((ref) async {
  final ui = ref.watch(timerUiProvider);
  final tagId = ui.selectedTagId;
  if (tagId == null) {
    return null;
  }
  // Config save updates the Tag row; re-read when the live list emits.
  await ref.watch(timerTagListProvider.future);
  return ref.watch(tagRepositoryProvider).getConfig(tagId, ui.selectedMode);
});

/// Initializes default tag when tag list loads.
final timerDefaultTagProvider = Provider<void>((ref) {
  final tagsAsync = ref.watch(timerTagListProvider);
  final ui = ref.watch(timerUiProvider);
  tagsAsync.whenData((tags) {
    if (tags.isNotEmpty && ui.selectedTagId == null) {
      ref.read(timerUiProvider.notifier).setTag(tags.first.id);
    }
  });
});
