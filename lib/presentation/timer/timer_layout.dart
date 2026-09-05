import 'package:flutter/material.dart';
import 'package:pomodoro_app/presentation/shared/app_layout.dart';

/// Max width per mode tab (Pomodoro / Flexible); total selector width is 2× this.
const kTimerModeTabMaxWidth = 200.0;

/// Max width for primary/secondary action buttons on timer screens.
const kTimerButtonMaxWidth = 200.0;

const kTimerButtonRowGap = 12.0;

/// Centers a single timer action button and caps width on tablet/wide layouts.
class TimerButtonSlot extends StatelessWidget {
  const TimerButtonSlot({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: kTimerButtonMaxWidth),
        child: SizedBox(width: double.infinity, child: child),
      ),
    );
  }
}

/// Two side-by-side timer buttons, each capped at [kTimerButtonMaxWidth].
class TimerButtonRow extends StatelessWidget {
  const TimerButtonRow({required this.start, required this.end, super.key});

  final Widget start;
  final Widget end;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: kTimerButtonMaxWidth * 2 + kTimerButtonRowGap,
        ),
        child: Row(
          children: [
            Expanded(child: start),
            const SizedBox(width: kTimerButtonRowGap),
            Expanded(child: end),
          ],
        ),
      ),
    );
  }
}

/// Compact control cluster (e.g. pause + stop) centered as one layout unit.
class TimerControlGroup extends StatelessWidget {
  const TimerControlGroup({required this.children, super.key});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) const SizedBox(width: kTimerButtonRowGap),
            children[i],
          ],
        ],
      ),
    );
  }
}

/// Full-height timer stage: [visual] stays vertically centered across states;
/// optional [header]/[footer] sit above/below without shifting the focal point.
class TimerStageLayout extends StatelessWidget {
  const TimerStageLayout({
    required this.visual,
    this.header,
    this.footer,
    super.key,
  });

  /// Timer readout, labels, countdown — the consistent focal cluster.
  final Widget visual;
  final Widget? header;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      child: Column(
        children: [
          ?header,
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: kAppContentMaxWidth,
                ),
                child: visual,
              ),
            ),
          ),
          if (footer != null) ...[const SizedBox(height: 16), footer!],
        ],
      ),
    );
  }
}
