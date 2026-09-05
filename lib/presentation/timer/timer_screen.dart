import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pomodoro_app/app/timer_providers.dart';
import 'package:pomodoro_app/application/timer/notification_strings.dart';
import 'package:pomodoro_app/application/timer/segment_end_copy.dart';
import 'package:pomodoro_app/application/timer/timer_view_state.dart';
import 'package:pomodoro_app/domain/common/enums.dart';
import 'package:pomodoro_app/presentation/l10n/l10n_extensions.dart';
import 'package:pomodoro_app/presentation/settings/alert_controls_section.dart';
import 'package:pomodoro_app/presentation/settings/settings_providers.dart';
import 'package:pomodoro_app/presentation/shared/app_layout.dart';
import 'package:pomodoro_app/presentation/shared/color_helpers.dart';
import 'package:pomodoro_app/presentation/tag/tag_providers.dart';
import 'package:pomodoro_app/presentation/timer/segment_labels.dart';
import 'package:pomodoro_app/presentation/timer/timer_actions.dart';
import 'package:pomodoro_app/presentation/timer/timer_format.dart';
import 'package:pomodoro_app/presentation/timer/timer_layout.dart';
import 'package:pomodoro_app/presentation/timer/timer_providers.dart';
import 'package:pomodoro_app/presentation/timer/timer_ui_state.dart';
import 'package:pomodoro_app/presentation/timer/widgets/mode_selector.dart';
import 'package:pomodoro_app/presentation/timer/widgets/recovery_dialog.dart';
import 'package:pomodoro_app/presentation/timer/widgets/slide_to_stop.dart';
import 'package:pomodoro_app/presentation/timer/widgets/tag_picker_field.dart';
import 'package:pomodoro_app/presentation/timer/widgets/timer_display_ring.dart';

class TimerScreen extends ConsumerStatefulWidget {
  const TimerScreen({this.deepLinkSessionId, super.key});

  final String? deepLinkSessionId;

  @override
  ConsumerState<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends ConsumerState<TimerScreen> {
  Timer? _tickTimer;
  bool _recoveryDialogShown = false;
  bool _deepLinkHandled = false;
  int _preStartGeneration = 0;
  bool _isFinishingPreStart = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _handleDeepLink();
      _maybeShowRecoveryDialog();
    });
  }

  @override
  void dispose() {
    _tickTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(timerDefaultTagProvider);
    // Chrome stream skips per-second ticks; full stream kept for tick sync + listen.
    final chromeAsync = ref.watch(timerChromeProvider);
    final ui = ref.watch(timerUiProvider);

    ref.listen<AsyncValue<TimerViewState>>(timerViewStateProvider, (
      prev,
      next,
    ) {
      final state = next.valueOrNull;
      if (state == null) {
        return;
      }
      _syncTickTimer(state);
      if (state.phase == EnginePhase.running ||
          state.phase == EnginePhase.paused) {
        ref.read(timerUiProvider.notifier).clearPreStart();
        _isFinishingPreStart = false;
      }
      if (state.showRecoveryPrompt && !_recoveryDialogShown) {
        _maybeShowRecoveryDialog();
      }
    });

    final l10n = context.l10n;
    final phase = chromeAsync.valueOrNull?.phase;
    final softComplete = phase == EnginePhase.sessionComplete;
    return PopScope(
      canPop: !softComplete,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) {
          return;
        }
        // Leaving soft session-complete without LANJUTKAN = Done.
        await runTimerAction(
          context,
          ref,
          () => ref.read(timerCoordinatorProvider).dismissSessionComplete(),
        );
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.timerTitle),
          actions: [
            if (chromeAsync.valueOrNull?.phase == EnginePhase.running)
              IconButton(
                tooltip: l10n.alertControlsSheetTitle,
                icon: const Icon(Icons.notifications_active_outlined),
                onPressed: () => showAlertControlsSheet(context),
              ),
            if (chromeAsync.valueOrNull?.phase == EnginePhase.running)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Center(
                  child: Icon(
                    Icons.brightness_high_outlined,
                    size: 18,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
          ],
        ),
        body: chromeAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, _) => Center(child: Text(l10n.timerLoadStateFailed)),
          data: (view) {
            final body = _buildTimerBody(view, ui);
            return AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              switchInCurve: Curves.easeOut,
              switchOutCurve: Curves.easeIn,
              child: KeyedSubtree(
                key: ValueKey(_timerBodyKey(view, ui)),
                child: body,
              ),
            );
          },
        ),
      ),
    );
  }

  String _timerBodyKey(TimerViewState view, TimerUiState ui) {
    if (ui.isPreStart && view.phase == EnginePhase.idle) {
      return 'prestart';
    }
    // Keep running/paused on one key so the pause↔resume icon can animate
    // without remounting the whole active timer body.
    if (view.phase == EnginePhase.running || view.phase == EnginePhase.paused) {
      return 'active';
    }
    return view.phase.name;
  }

  Widget _buildTimerBody(TimerViewState view, TimerUiState ui) {
    if (ui.isPreStart && view.phase == EnginePhase.idle) {
      return _PreStartBody(
        countdown: ui.preStartCountdown!,
        onSkip: () => _finishPreStart(skipCountdown: true),
      );
    }

    return switch (view.phase) {
      EnginePhase.idle => _IdleBody(view: view, onStart: _onStartPressed),
      EnginePhase.running => _ActiveBody(view: view, isPaused: false),
      EnginePhase.paused => _ActiveBody(view: view, isPaused: true),
      EnginePhase.segmentComplete => _SegmentCompleteBody(view: view),
      EnginePhase.sessionComplete => _SessionCompleteBody(view: view),
    };
  }

  void _syncTickTimer(TimerViewState view) {
    final shouldTick = view.phase == EnginePhase.running;
    if (shouldTick && _tickTimer == null) {
      _tickTimer = Timer.periodic(const Duration(seconds: 1), (_) {
        ref.read(timerCoordinatorProvider).tick();
      });
    } else if (!shouldTick) {
      _tickTimer?.cancel();
      _tickTimer = null;
    }
  }

  Future<void> _onStartPressed() async {
    final ui = ref.read(timerUiProvider);
    final tagId = ui.selectedTagId;
    if (tagId == null) {
      showTimerMessage(context, context.l10n.selectTagFirst);
      return;
    }
    if (ui.selectedMode == TimerMode.pomodoro) {
      _preStartGeneration++;
      _isFinishingPreStart = false;
      ref.read(timerUiProvider.notifier).startPreStartCountdown();
      _preStartTick(_preStartGeneration);
      return;
    }
    await runTimerAction(
      context,
      ref,
      () => ref.read(timerCoordinatorProvider).startFlexible(tagId),
    );
  }

  void _preStartTick(int generation) {
    Future<void> tick() async {
      if (!mounted || generation != _preStartGeneration) {
        return;
      }
      final ui = ref.read(timerUiProvider);
      if (!ui.isPreStart) {
        return;
      }
      if (ui.preStartCountdown == 0) {
        await _finishPreStart(skipCountdown: false);
        return;
      }
      await Future<void>.delayed(const Duration(seconds: 1));
      if (!mounted || generation != _preStartGeneration) {
        return;
      }
      ref.read(timerUiProvider.notifier).tickPreStart();
      final after = ref.read(timerUiProvider);
      if (after.preStartCountdown == 0) {
        await _finishPreStart(skipCountdown: false);
      } else if (after.isPreStart) {
        tick();
      }
    }

    tick();
  }

  Future<void> _finishPreStart({required bool skipCountdown}) async {
    if (_isFinishingPreStart) {
      return;
    }
    _isFinishingPreStart = true;
    _preStartGeneration++;

    final uiNotifier = ref.read(timerUiProvider.notifier);
    if (skipCountdown) {
      uiNotifier.markPreStartLaunching();
    }

    final tagId = ref.read(timerUiProvider).selectedTagId;
    if (tagId == null) {
      _isFinishingPreStart = false;
      uiNotifier.clearPreStart();
      return;
    }

    final ok = await runTimerAction(
      context,
      ref,
      () => ref.read(timerCoordinatorProvider).startPomodoro(tagId),
    );
    if (!mounted) {
      return;
    }
    if (ok) {
      uiNotifier.clearPreStart();
    }
    _isFinishingPreStart = false;
  }

  void _handleDeepLink() {
    if (_deepLinkHandled) {
      return;
    }
    _deepLinkHandled = true;
    final sessionId = widget.deepLinkSessionId;
    if (sessionId == null) {
      return;
    }
    final view = ref.read(timerViewStateProvider).valueOrNull;
    if (view?.sessionId != sessionId) {
      showTimerMessage(context, context.l10n.errorSessionNotActiveOrEnded);
    }
  }

  Future<void> _maybeShowRecoveryDialog() async {
    final view = ref.read(timerViewStateProvider).valueOrNull;
    if (view == null || !view.showRecoveryPrompt || _recoveryDialogShown) {
      return;
    }
    _recoveryDialogShown = true;
    await RecoveryDialog.showIfNeeded(
      context,
      show: true,
      onResume: () async {
        await runTimerAction(
          context,
          ref,
          () => ref.read(timerCoordinatorProvider).resumeFromPersisted(),
        );
      },
      onDecline: () async {
        await runTimerAction(
          context,
          ref,
          () => ref.read(timerCoordinatorProvider).declineRecovery(),
        );
        _recoveryDialogShown = false;
      },
    );
  }
}

class _IdleBody extends ConsumerWidget {
  const _IdleBody({required this.view, required this.onStart});

  final TimerViewState view;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final ui = ref.watch(timerUiProvider);
    final configAsync = ref.watch(selectedTagConfigProvider);

    final previewSec = configAsync.valueOrNull?.focusDurationSec ?? 1500;
    final reminderEnabled = configAsync.valueOrNull?.reminderEnabled ?? false;
    final reminderMin = configAsync.valueOrNull?.reminderIntervalMin;

    return TimerStageLayout(
      header: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ModeSelector(
            selected: ui.selectedMode,
            onChanged: ref.read(timerUiProvider.notifier).setMode,
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.center,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: kAppContentMaxWidth),
              child: const SizedBox(
                width: double.infinity,
                child: TagPickerField(enabled: true),
              ),
            ),
          ),
        ],
      ),
      visual: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            formatTimerSeconds(
              ui.selectedMode == TimerMode.pomodoro ? previewSec : 0,
            ),
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
              fontWeight: FontWeight.w600,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(height: 4),
          if (ui.selectedMode == TimerMode.flexible && reminderEnabled) ...[
            const SizedBox(height: 16),
            Text(
              l10n.flexibleReminderEveryMinutes(reminderMin ?? 25),
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
      footer: TimerButtonSlot(
        child: FilledButton(
          onPressed: ui.selectedTagId == null ? null : onStart,
          style: FilledButton.styleFrom(
            minimumSize: const Size(double.infinity, 52),
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
          ),
          child: Text(l10n.start.toUpperCase()),
        ),
      ),
    );
  }
}

class _PreStartBody extends StatelessWidget {
  const _PreStartBody({required this.countdown, required this.onSkip});

  final int countdown;
  final VoidCallback onSkip;

  bool get _isLaunching => countdown <= 0;

  @override
  Widget build(BuildContext context) {
    return TimerStageLayout(
      visual: Text(
        _isLaunching ? '…' : '$countdown',
        style: Theme.of(context).textTheme.displayLarge,
        textAlign: TextAlign.center,
      ),
      footer: _isLaunching
          ? null
          : TimerButtonSlot(
              child: TextButton(
                onPressed: onSkip,
                child: Text(context.l10n.skip),
              ),
            ),
    );
  }
}

class _ActiveBody extends ConsumerWidget {
  const _ActiveBody({required this.view, required this.isPaused});

  final TimerViewState view;
  final bool isPaused;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final isRest = isRestSegment(view.currentSegmentType);
    final tagColor = _resolveTagColor(ref, view.tagId);

    return TimerStageLayout(
      header: _ActiveSessionChips(
        tagName: view.tagName,
        tagColor: tagColor,
        segmentLabel: segmentTypeLabel(l10n, view.currentSegmentType),
        sessionProgress: _sessionProgressLabel(view),
      ),
      visual: const _LiveTimerDisplayRing(),
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
                        duration: const Duration(milliseconds: 280),
                        switchInCurve: Curves.easeOutBack,
                        switchOutCurve: Curves.easeIn,
                        transitionBuilder: (child, animation) {
                          return FadeTransition(
                            opacity: animation,
                            child: ScaleTransition(
                              scale: Tween<double>(
                                begin: 0.55,
                                end: 1,
                              ).animate(animation),
                              child: child,
                            ),
                          );
                        },
                        child: Icon(
                          isPaused
                              ? Icons.play_arrow_rounded
                              : Icons.pause_rounded,
                          key: ValueKey(isPaused ? 'resume' : 'pause'),
                          size: 28,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const _LiveSlideToStop(),
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

  Color? _resolveTagColor(WidgetRef ref, String? tagId) {
    if (tagId == null) {
      return null;
    }
    final tags = ref.watch(tagListProvider).valueOrNull;
    if (tags == null) {
      return null;
    }
    for (final tag in tags) {
      if (tag.id == tagId) {
        return parseHexColor(tag.color);
      }
    }
    return null;
  }

  /// Focus-in-cycle progress, e.g. `1/4` while the first focus is running.
  String? _sessionProgressLabel(TimerViewState view) {
    if (view.mode != TimerMode.pomodoro || view.totalFocusInCycle <= 0) {
      return null;
    }
    final current = view.currentSegmentType == SegmentType.focus
        ? view.completedFocusCount + 1
        : view.completedFocusCount.clamp(1, view.totalFocusInCycle);
    return '$current/${view.totalFocusInCycle}';
  }
}

/// Per-second display only — keeps [_ActiveBody] chrome off the tick path.
class _LiveTimerDisplayRing extends ConsumerWidget {
  const _LiveTimerDisplayRing();

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
    );
  }
}

class _LiveSlideToStop extends ConsumerWidget {
  const _LiveSlideToStop();

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

class _ActiveSessionChips extends StatelessWidget {
  const _ActiveSessionChips({
    required this.tagName,
    required this.tagColor,
    required this.segmentLabel,
    required this.sessionProgress,
  });

  /// Spec: Tag chip max width as a fraction of available header width.
  static const double _tagMaxWidthFraction = 0.4;

  final String? tagName;
  final Color? tagColor;
  final String segmentLabel;
  final String? sessionProgress;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final tagMaxWidth = constraints.maxWidth * _tagMaxWidthFraction;
        final chips = <Widget>[
          if (tagName != null && tagName!.isNotEmpty)
            _TimerInfoChip(
              icon: Icons.label_outline,
              label: tagName!,
              iconColor: tagColor ?? scheme.primary,
              background: (tagColor ?? scheme.primary).withValues(alpha: 0.12),
              foreground: scheme.onSurface,
              emphasized: true,
              maxWidth: tagMaxWidth,
            ),
          if (segmentLabel.isNotEmpty)
            _TimerInfoChip(
              icon: Icons.timelapse_outlined,
              label: segmentLabel,
              iconColor: scheme.secondary,
              background: scheme.secondaryContainer.withValues(alpha: 0.55),
              foreground: scheme.onSecondaryContainer,
            ),
          if (sessionProgress != null)
            _TimerInfoChip(
              icon: Icons.repeat,
              label: sessionProgress!,
              iconColor: scheme.tertiary,
              background: scheme.surfaceContainerHighest,
              foreground: scheme.onSurfaceVariant,
            ),
        ];

        if (chips.isEmpty) {
          return const SizedBox.shrink();
        }

        return Align(
          alignment: Alignment.center,
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: chips,
          ),
        );
      },
    );
  }
}

class _TimerInfoChip extends StatelessWidget {
  const _TimerInfoChip({
    required this.icon,
    required this.label,
    required this.iconColor,
    required this.background,
    required this.foreground,
    this.emphasized = false,
    this.maxWidth,
  });

  final IconData icon;
  final String label;
  final Color iconColor;
  final Color background;
  final Color foreground;

  /// Soft emphasis: heavier weight only — same icon/font size as other chips.
  final bool emphasized;
  final double? maxWidth;

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.labelMedium?.copyWith(
      color: foreground,
      fontWeight: emphasized ? FontWeight.w600 : FontWeight.w500,
    );

    final labelText = Text(
      label,
      style: textStyle,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      softWrap: false,
    );

    Widget chip = Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: iconColor),
          const SizedBox(width: 6),
          if (maxWidth != null) Flexible(child: labelText) else labelText,
        ],
      ),
    );

    if (maxWidth != null) {
      chip = ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth!),
        child: chip,
      );
    }

    return chip;
  }
}

class _SegmentCompleteBody extends ConsumerWidget {
  const _SegmentCompleteBody({required this.view});

  final TimerViewState view;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final language = ref
        .watch(appSettingsStreamProvider)
        .maybeWhen(data: (s) => s.language, orElse: () => 'en');
    final endCopy = view.hasSegmentEndSummary
        ? SegmentEndCopy.build(
            strings: NotificationStrings.forLanguage(language),
            finished: view.segmentEndFinishedType!,
            next: view.segmentEndNextType,
            completedCount: view.segmentEndCompletedCount!,
            totalCount: view.segmentEndTotalCount!,
          )
        : null;
    final nextIsRest = view.currentSegmentType == SegmentType.focus;
    final title =
        endCopy?.title ??
        (nextIsRest ? l10n.focusCompleteTitle : l10n.breakCompleteTitle);
    final body =
        endCopy?.body ??
        (nextIsRest ? l10n.timeForBreak : l10n.readyForNextFocus);

    return TimerStageLayout(
      visual: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 72,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(body, textAlign: TextAlign.center),
        ],
      ),
      footer: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TimerButtonSlot(
            child: FilledButton(
              onPressed: () => runTimerAction(
                context,
                ref,
                () => ref.read(timerCoordinatorProvider).advanceSegment(),
              ),
              style: FilledButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
              ),
              child: Text(
                nextIsRest ? l10n.startBreakUpper : l10n.startFocusUpper,
              ),
            ),
          ),
          if (nextIsRest) ...[
            const SizedBox(height: 8),
            TimerButtonSlot(
              child: TextButton(
                onPressed: () => runTimerAction(
                  context,
                  ref,
                  () => ref.read(timerCoordinatorProvider).skipBreak(),
                ),
                child: Text(l10n.skipBreak),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SessionCompleteBody extends ConsumerWidget {
  const _SessionCompleteBody({required this.view});

  final TimerViewState view;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final isPomodoro = view.mode == TimerMode.pomodoro;
    final duration = formatTimerSeconds(view.displaySec, forceHours: true);
    final language = ref
        .watch(appSettingsStreamProvider)
        .maybeWhen(data: (s) => s.language, orElse: () => 'en');
    final endCopy = view.hasSegmentEndSummary
        ? SegmentEndCopy.build(
            strings: NotificationStrings.forLanguage(language),
            finished: view.segmentEndFinishedType!,
            next: view.segmentEndNextType,
            completedCount: view.segmentEndCompletedCount!,
            totalCount: view.segmentEndTotalCount!,
            sessionComplete: true,
          )
        : null;

    return TimerStageLayout(
      visual: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            endCopy?.title ?? l10n.sessionCompleteTitle,
            style: Theme.of(context).textTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),
          if (endCopy != null) ...[
            const SizedBox(height: 8),
            Text(endCopy.body, textAlign: TextAlign.center),
          ],
          if (!isPomodoro) ...[
            const SizedBox(height: 8),
            Text(l10n.sessionSavedBody, textAlign: TextAlign.center),
          ],
          const SizedBox(height: 8),
          Text(l10n.activeDuration(duration), textAlign: TextAlign.center),
          if (isPomodoro && view.completedCycleCount != null) ...[
            const SizedBox(height: 8),
            Text(
              l10n.cycleProgress(
                view.completedCycleCount!,
                view.totalCycleTarget!,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
      footer: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TimerButtonSlot(
            child: FilledButton(
              onPressed: () => runTimerAction(
                context,
                ref,
                () => isPomodoro
                    ? ref.read(timerCoordinatorProvider).continuePomodoro()
                    : ref.read(timerCoordinatorProvider).restartSameTag(),
              ),
              style: FilledButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
              ),
              child: Text(
                isPomodoro ? l10n.continueUpper : l10n.startAgainUpper,
              ),
            ),
          ),
          const SizedBox(height: 8),
          TimerButtonSlot(
            child: OutlinedButton(
              onPressed: () => runTimerAction(
                context,
                ref,
                () =>
                    ref.read(timerCoordinatorProvider).dismissSessionComplete(),
              ),
              child: Text(l10n.doneUpper),
            ),
          ),
        ],
      ),
    );
  }
}
