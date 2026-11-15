import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pomodoro_app/app/timer_providers.dart';
import 'package:pomodoro_app/application/timer/notification_strings.dart';
import 'package:pomodoro_app/application/timer/segment_end_copy.dart';
import 'package:pomodoro_app/application/timer/timer_view_state.dart';
import 'package:pomodoro_app/domain/common/enums.dart';
import 'package:pomodoro_app/presentation/l10n/l10n_extensions.dart';
import 'package:pomodoro_app/presentation/settings/settings_providers.dart';
import 'package:pomodoro_app/presentation/shared/phosphor_icon_data.dart';
import 'package:pomodoro_app/presentation/timer/timer_actions.dart';
import 'package:pomodoro_app/presentation/timer/timer_layout.dart';

class TimerSegmentCompleteBody extends ConsumerWidget {
  const TimerSegmentCompleteBody({required this.view, super.key});

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
            PresentationPhosphorIcons.checkCircle(),
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
          Text(
            body,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
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