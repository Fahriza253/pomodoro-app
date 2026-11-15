import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pomodoro_app/app/timer_providers.dart';
import 'package:pomodoro_app/application/timer/timer_flow_state.dart';
import 'package:pomodoro_app/application/timer/timer_view_state.dart';
import 'package:pomodoro_app/domain/common/enums.dart';
import 'package:pomodoro_app/presentation/l10n/l10n_extensions.dart';
import 'package:pomodoro_app/presentation/settings/alert_controls_section.dart';
import 'package:pomodoro_app/presentation/settings/settings_providers.dart';
import 'package:pomodoro_app/presentation/shared/phosphor_icon_data.dart';
import 'package:pomodoro_app/presentation/timer/timer_actions.dart';
import 'package:pomodoro_app/presentation/timer/timer_providers.dart';
import 'package:pomodoro_app/presentation/timer/timer_ui_state.dart';
import 'package:pomodoro_app/presentation/timer/widgets/recovery_dialog.dart';
import 'package:pomodoro_app/presentation/timer/widgets/timer_active_body.dart';
import 'package:pomodoro_app/presentation/timer/widgets/timer_idle_body.dart';
import 'package:pomodoro_app/presentation/timer/widgets/timer_pre_start_body.dart';
import 'package:pomodoro_app/presentation/timer/widgets/timer_recovery_placeholder.dart';
import 'package:pomodoro_app/presentation/timer/widgets/timer_segment_complete_body.dart';
import 'package:pomodoro_app/presentation/timer/widgets/timer_session_complete_body.dart';
import 'package:pomodoro_app/presentation/timer/widgets/timer_stage_switcher.dart';
import 'package:pomodoro_app/presentation/timer/widgets/timer_start_settings_section.dart';

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
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _handleDeepLink();
      final flow = ref.read(timerFlowStateProvider).valueOrNull;
      if (flow is TimerRecoveryOfferFlow) {
        unawaited(_maybeShowRecoveryDialog(flow));
      }
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
    final flowChromeAsync = ref.watch(timerFlowChromeProvider);
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
    });

    ref.listen<AsyncValue<TimerFlowState>>(timerFlowStateProvider, (
      prev,
      next,
    ) {
      final flow = next.valueOrNull;
      if (flow is TimerRecoveryOfferFlow && !_recoveryDialogShown) {
        unawaited(_maybeShowRecoveryDialog(flow));
      }
    });

    final l10n = context.l10n;
    final phase = chromeAsync.valueOrNull?.phase;
    final softComplete = phase == EnginePhase.sessionComplete;
    final flowChrome = flowChromeAsync.valueOrNull;
    final inPreStart = flowChrome is TimerPomodoroPreStartFlow;
    final inActiveRun =
        phase == EnginePhase.running || phase == EnginePhase.paused;
    return PopScope(
      canPop: !softComplete && !inPreStart,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) {
          return;
        }
        if (softComplete) {
          await runTimerAction(
            context,
            ref,
            () => ref.read(timerCoordinatorProvider).dismissSessionComplete(),
          );
          return;
        }
        final flow = ref.read(timerFlowChromeProvider).valueOrNull;
        if (flow is TimerPomodoroPreStartFlow && flow.actions.canCancel) {
          ref.read(timerCoordinatorProvider).cancelPreStart();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.timerTitle),
          actions: [
            if (!inActiveRun)
              IconButton(
                tooltip: l10n.timerStartSettingsSheetTitle,
                icon: const Icon(PresentationPhosphorIcons.fadersHorizontal),
                onPressed: () => showTimerStartSettingsSheet(context),
              ),
            if (phase == EnginePhase.running)
              IconButton(
                tooltip: l10n.alertControlsSheetTitle,
                icon: const Icon(PresentationPhosphorIcons.bellRinging),
                onPressed: () => showAlertControlsSheet(context),
              ),
          ],
        ),
        body: flowChromeAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, _) => Center(child: Text(l10n.timerLoadStateFailed)),
          data: (flow) {
            final view = chromeAsync.valueOrNull;
            if (view == null) {
              return const Center(child: CircularProgressIndicator());
            }
            final body = _buildTimerBody(flow, view, ui);
            final bodyKey = _timerBodyKey(flow, view);
            return TimerStageSwitcher(
              stageKey: bodyKey,
              child: body,
            );
          },
        ),
      ),
    );
  }

  String _timerBodyKey(TimerFlowState flow, TimerViewState view) {
    if (flow is TimerPomodoroPreStartFlow) {
      return 'pomodoro-prestart';
    }
    return switch (flow) {
      TimerIdleSetupFlow() => 'idle',
      TimerRecoveryOfferFlow() => 'recovery',
      _ => switch (view.phase) {
        EnginePhase.running || EnginePhase.paused =>
          view.mode == TimerMode.pomodoro ? 'pomodoro-run' : 'flex-active',
        _ => view.phase.name,
      },
    };
  }

  Widget _buildTimerBody(
    TimerFlowState flow,
    TimerViewState view,
    TimerUiState ui,
  ) {
    return switch (flow) {
      TimerIdleSetupFlow(:final actions) => TimerIdleBody(
        canStartSession: actions.canStartSession,
        onStart: _onStartPressed,
      ),
      TimerPomodoroPreStartFlow(
        :final tagId,
        :final countdownSeconds,
        :final actions,
      ) =>
        TimerPreStartBody(
          tagId: tagId,
          countdown: countdownSeconds,
          onSkip: actions.canSkip ? _skipPreStart : null,
        ),
      TimerRecoveryOfferFlow() => const TimerRecoveryOfferPlaceholder(),
      _ => switch (view.phase) {
        EnginePhase.running => TimerActiveBody(view: view, isPaused: false),
        EnginePhase.paused => TimerActiveBody(view: view, isPaused: true),
        EnginePhase.segmentComplete => TimerSegmentCompleteBody(view: view),
        EnginePhase.sessionComplete => TimerSessionCompleteBody(view: view),
        EnginePhase.idle => const TimerRecoveryOfferPlaceholder(),
      },
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
      final preStart = ref
              .read(appSettingsStreamProvider)
              .valueOrNull
              ?.pomodoroPreStartCountdown ??
          false;
      await runTimerAction(
        context,
        ref,
        () async => ref.read(timerCoordinatorProvider).beginPomodoroStart(
              tagId,
              preStartCountdown: preStart,
            ),
      );
      return;
    }
    await runTimerAction(
      context,
      ref,
      () => ref.read(timerCoordinatorProvider).startFlexible(tagId),
    );
  }

  Future<void> _skipPreStart() async {
    await runTimerAction(
      context,
      ref,
      () => ref.read(timerCoordinatorProvider).skipPreStartAndLaunch(),
    );
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

  Future<void> _maybeShowRecoveryDialog(TimerRecoveryOfferFlow offer) async {
    if (_recoveryDialogShown) {
      return;
    }
    _recoveryDialogShown = true;
    await RecoveryDialog.showIfNeeded(
      context,
      show: offer.actions.canResume || offer.actions.canDecline,
      onResume: () async {
        if (!offer.actions.canResume) {
          return;
        }
        await runTimerAction(
          context,
          ref,
          () => ref.read(timerCoordinatorProvider).resumeFromPersisted(),
        );
      },
      onDecline: () async {
        if (!offer.actions.canDecline) {
          return;
        }
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