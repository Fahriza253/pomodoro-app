import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pomodoro_app/app/timer_providers.dart';
import 'package:pomodoro_app/application/timer/timer_view_state.dart';
import 'package:pomodoro_app/domain/common/enums.dart';
import 'package:pomodoro_app/presentation/l10n/l10n_extensions.dart';
import 'package:pomodoro_app/presentation/shared/phosphor_icon_data.dart';
import 'package:pomodoro_app/presentation/timer/segment_labels.dart';
import 'package:pomodoro_app/presentation/timer/timer_actions.dart';
import 'package:pomodoro_app/presentation/timer/timer_layout.dart';
import 'package:pomodoro_app/presentation/timer/timer_providers.dart';
import 'package:pomodoro_app/presentation/timer/widgets/slide_to_stop.dart';
import 'package:pomodoro_app/presentation/timer/widgets/timer_active_session_chips.dart';
import 'package:pomodoro_app/presentation/timer/widgets/timer_display_ring.dart';

class TimerActiveBody extends ConsumerWidget {
  const TimerActiveBody({
    required this.view,
    required this.isPaused,
    super.key,
  });

  final TimerViewState view;
  final bool isPaused;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final isRest = isRestSegment(view.currentSegmentType);
    return TimerStageLayout(
      header: TimerActiveSessionChips(
        tagName: view.tagName,
        segmentType: view.currentSegmentType ?? SegmentType.focus,
        segmentLabel: segmentTypeLabel(l10n, view.currentSegmentType),
        sessionProgress: pomodoroSessionProgressLabel(view),
      ),
      visual: const LiveTimerDisplayRing(),
      footer: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TimerControlGroup(
            children: [
              SizedBox(
                width: 56,
                height: 56,
                child: OutlinedButton(
                  onPressed: isPaused
                      ? () => runTimerAction(
                          context,
                          ref,
                          () => ref.read(timerCoordinatorProvider).resume(),
                        )
                      : () => runTimerAction(
                          context,
                          ref,
                          () => ref.read(timerCoordinatorProvider).pause(),
                        ),
                  style: OutlinedButton.styleFrom(
                    shape: const CircleBorder(),
                    padding: EdgeInsets.zero,
                    minimumSize: const Size.square(56),
                    maximumSize: const Size.square(56),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Semantics(
                    button: true,
                    label: isPaused ? l10n.resume : l10n.pause,
                    child: ExcludeSemantics(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 220),
                        switchInCurve: Curves.easeOutCubic,
                        switchOutCurve: Curves.easeInCubic,
                        transitionBuilder: (child, animation) {
                          return FadeTransition(
                            opacity: animation,
                            child: ScaleTransition(
                              scale: Tween<double>(
                                begin: 0.92,
                                end: 1,
                              ).animate(animation),
                              child: child,
                            ),
                          );
                        },
                        child: Icon(
                          isPaused
                              ? PresentationPhosphorIcons.play()
                              : PresentationPhosphorIcons.pause(filled: true),
                          key: ValueKey(isPaused ? 'resume' : 'pause'),
                          size: 28,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const LiveSlideToStop(),
            ],
          ),
          if (isRest && !isPaused) ...[
            const SizedBox(height: 12),
            TimerButtonSlot(
              child: TextButton(
                onPressed: () => runTimerAction(
                  context,
                  ref,
                  () => ref.read(timerCoordinatorProvider).skipBreak(),
                ),
                child: Text(l10n.skipBreakUpper),
              ),
            ),
          ],
          if (view.mode == TimerMode.flexible) ...[
            const SizedBox(height: 12),
            TimerButtonSlot(
              child: FilledButton(
                onPressed: () => runTimerAction(
                  context,
                  ref,
                  () => ref.read(timerCoordinatorProvider).completeFlexible(),
                ),
                child: Text(l10n.finish.toUpperCase()),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Focus-in-cycle progress, e.g. `1/4` while the first focus is running.
String? pomodoroSessionProgressLabel(TimerViewState view) {
  if (view.mode != TimerMode.pomodoro || view.totalFocusInCycle <= 0) {
    return null;
  }
  final current = view.currentSegmentType == SegmentType.focus
      ? view.completedFocusCount + 1
      : view.completedFocusCount.clamp(1, view.totalFocusInCycle);
  return '$current/${view.totalFocusInCycle}';
}

/// Per-second display only; keeps [TimerActiveBody] chrome off the tick path.
class LiveTimerDisplayRing extends ConsumerWidget {
  const LiveTimerDisplayRing({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final view = ref.watch(timerViewStateProvider).valueOrNull;
    if (view == null) {
      return const SizedBox(width: 220, height: 220);
    }
    return TimerDisplayRing(
      displaySec: view.displaySec,
      isCountdown: view.isCountdown,
      plannedSec: view.currentPlannedSec,
      segmentType: view.currentSegmentType ?? SegmentType.focus,
    );
  }
}

class LiveSlideToStop extends ConsumerWidget {
  const LiveSlideToStop({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final view = ref.watch(timerViewStateProvider).valueOrNull;
    final l10n = context.l10n;
    final grace = view?.earlyStopGraceRemainingSec ?? 0;
    return SlideToStop(
      idleLabel: grace > 0
          ? l10n.stopWithGraceSeconds(grace).toUpperCase()
          : l10n.stop.toUpperCase(),
      onStop: () => stopSession(context, ref),
    );
  }
}