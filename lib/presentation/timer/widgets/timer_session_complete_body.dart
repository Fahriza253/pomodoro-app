import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pomodoro_app/app/timer_providers.dart';
import 'package:pomodoro_app/application/timer/timer_view_state.dart';
import 'package:pomodoro_app/presentation/l10n/l10n_extensions.dart';
import 'package:pomodoro_app/presentation/settings/settings_providers.dart';
import 'package:pomodoro_app/presentation/timer/soft_complete_presentation_intent.dart';
import 'package:pomodoro_app/presentation/timer/timer_actions.dart';
import 'package:pomodoro_app/presentation/timer/timer_layout.dart';
import 'package:pomodoro_app/presentation/timer/widgets/session_complete_lottie.dart';

class TimerSessionCompleteBody extends ConsumerStatefulWidget {
  const TimerSessionCompleteBody({required this.view, super.key});

  final TimerViewState view;

  @override
  ConsumerState<TimerSessionCompleteBody> createState() =>
      _TimerSessionCompleteBodyState();
}

class _TimerSessionCompleteBodyState
    extends ConsumerState<TimerSessionCompleteBody> {
  late final SoftCompletePresentationIntent _intent =
      SoftCompletePresentationIntent();

  Future<bool> _run(SoftCompleteWireTarget wire) {
    final coordinator = ref.read(timerCoordinatorProvider);
    return runTimerAction(
      context,
      ref,
      () => switch (wire) {
        SoftCompleteWireTarget.restartSameTag => coordinator.restartSameTag(),
        SoftCompleteWireTarget.dismissSessionComplete =>
          coordinator.dismissSessionComplete(),
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final language = ref
        .watch(appSettingsStreamProvider)
        .maybeWhen(data: (s) => s.language, orElse: () => 'en');
    final screen = _intent.present(
      view: widget.view,
      l10n: context.l10n,
      languageCode: language,
    );

    return switch (screen) {
      SoftCompleteCelebration(
        :final lottieAsset,
        :final headline,
        :final body,
        :final primary,
        :final secondary,
      ) =>
        TimerStageLayout(
          visual: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SessionCompleteLottie(asset: lottieAsset),
              const SizedBox(height: 16),
              Text(
                headline,
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(body, textAlign: TextAlign.center),
            ],
          ),
          footer: _footer(primary, secondary),
        ),
      SoftCompleteSimple(
        :final headline,
        :final segmentEndBody,
        :final savedLine,
        :final durationLine,
        :final primary,
        :final secondary,
      ) =>
        TimerStageLayout(
          visual: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                headline,
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              if (segmentEndBody != null) ...[
                const SizedBox(height: 8),
                Text(segmentEndBody, textAlign: TextAlign.center),
              ],
              const SizedBox(height: 8),
              Text(savedLine, textAlign: TextAlign.center),
              const SizedBox(height: 8),
              Text(durationLine, textAlign: TextAlign.center),
            ],
          ),
          footer: _footer(primary, secondary),
        ),
    };
  }

  Widget _footer(SoftCompleteAction primary, SoftCompleteAction secondary) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TimerButtonSlot(
          child: FilledButton(
            onPressed: () => _run(primary.wire),
            style: FilledButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
            ),
            child: Text(primary.label),
          ),
        ),
        const SizedBox(height: 8),
        TimerButtonSlot(
          child: OutlinedButton(
            onPressed: () => _run(secondary.wire),
            child: Text(secondary.label),
          ),
        ),
      ],
    );
  }
}