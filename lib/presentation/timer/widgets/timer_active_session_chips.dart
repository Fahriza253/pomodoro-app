import 'package:flutter/material.dart';
import 'package:pomodoro_app/app/theme/segment_semantic_color.dart';
import 'package:pomodoro_app/domain/common/enums.dart';
import 'package:pomodoro_app/presentation/shared/phosphor_icon_data.dart';
import 'package:pomodoro_app/presentation/timer/widgets/timer_info_chip.dart';

class TimerActiveSessionChips extends StatelessWidget {
  const TimerActiveSessionChips({
    required this.tagName,
    required this.segmentType,
    required this.segmentLabel,
    required this.sessionProgress,
    super.key,
  });

  /// Spec: Tag chip max width as a fraction of available header width.
  static const double tagMaxWidthFraction = 0.4;

  final String? tagName;
  final SegmentType segmentType;
  final String segmentLabel;
  final String? sessionProgress;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final segmentEmphasis = segmentSemanticEmphasis(scheme, segmentType);

    return LayoutBuilder(
      builder: (context, constraints) {
        final tagMaxWidth = constraints.maxWidth * tagMaxWidthFraction;
        final chips = <Widget>[
          if (tagName != null && tagName!.isNotEmpty)
            TimerInfoChip(
              icon: PresentationPhosphorIcons.tag,
              label: tagName!,
              iconColor: scheme.onSurfaceVariant,
              background: scheme.surfaceContainerHighest,
              foreground: scheme.onSurface,
              emphasized: true,
              maxWidth: tagMaxWidth,
            ),
          if (segmentLabel.isNotEmpty)
            TimerInfoChip(
              icon: PresentationPhosphorIcons.hourglass,
              label: segmentLabel,
              iconColor: segmentEmphasis.accent,
              background: segmentEmphasis.background,
              foreground: segmentEmphasis.foreground,
            ),
          if (sessionProgress != null)
            TimerInfoChip(
              icon: PresentationPhosphorIcons.repeat,
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