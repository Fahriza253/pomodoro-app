import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pomodoro_app/domain/common/enums.dart';
import 'package:pomodoro_app/presentation/l10n/l10n_extensions.dart';
import 'package:pomodoro_app/presentation/shared/app_layout.dart';
import 'package:pomodoro_app/presentation/timer/timer_format.dart';
import 'package:pomodoro_app/presentation/timer/timer_layout.dart';
import 'package:pomodoro_app/presentation/timer/timer_providers.dart';
import 'package:pomodoro_app/presentation/timer/widgets/tag_picker_field.dart';

class TimerIdleBody extends ConsumerWidget {
  const TimerIdleBody({
    required this.canStartSession,
    required this.onStart,
    super.key,
  });

  final bool canStartSession;
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
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          if (ui.selectedMode == TimerMode.flexible && reminderEnabled) ...[
            const SizedBox(height: 8),
            Text(
              l10n.flexibleReminderEveryMinutes(reminderMin ?? 25),
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
      footer: TimerButtonSlot(
        child: FilledButton(
          onPressed: canStartSession && ui.selectedTagId != null
              ? onStart
              : null,
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