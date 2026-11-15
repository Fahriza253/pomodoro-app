import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pomodoro_app/domain/common/enums.dart';
import 'package:pomodoro_app/presentation/l10n/l10n_extensions.dart';
import 'package:pomodoro_app/presentation/tag/tag_providers.dart';
import 'package:pomodoro_app/presentation/timer/segment_labels.dart';
import 'package:pomodoro_app/presentation/timer/timer_layout.dart';
import 'package:pomodoro_app/presentation/timer/widgets/timer_active_session_chips.dart';
import 'package:pomodoro_app/presentation/timer/widgets/timer_display_ring.dart';

class TimerPreStartBody extends ConsumerWidget {
  const TimerPreStartBody({
    required this.tagId,
    required this.countdown,
    this.onSkip,
    super.key,
  });

  final String tagId;
  final int countdown;
  final VoidCallback? onSkip;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final tags = ref.watch(timerTagListProvider).valueOrNull ?? const [];
    final tagName = tags
        .where((t) => t.id == tagId)
        .map((t) => t.name)
        .firstOrNull;
    final scheme = Theme.of(context).colorScheme;
    final countdownStyle = Theme.of(context).textTheme.displayLarge?.copyWith(
      fontWeight: FontWeight.w700,
      color: scheme.onSurface,
      fontFeatures: const [FontFeature.tabularFigures()],
    );

    return TimerStageLayout(
      header: TimerActiveSessionChips(
        tagName: tagName,
        segmentType: SegmentType.focus,
        segmentLabel: segmentTypeLabel(l10n, SegmentType.focus),
        sessionProgress: null,
      ),
      visual: TimerDisplayRing(
        displaySec: countdown,
        isCountdown: false,
        plannedSec: null,
        segmentType: SegmentType.focus,
        showRing: true,
        centerChild: Text(
          '$countdown',
          style: countdownStyle,
          textAlign: TextAlign.center,
        ),
      ),
      footer: onSkip == null
          ? null
          : TimerButtonSlot(
              child: TextButton(
                onPressed: onSkip,
                child: Text(l10n.skip),
              ),
            ),
    );
  }
}