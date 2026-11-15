import 'package:flutter/material.dart';
import 'package:pomodoro_app/presentation/shared/app_layout.dart';

/// Max width per mode tab (Pomodoro / Flexible); total selector width is 2× this.
const kTimerModeTabMaxWidth = 200.0;

/// Max width for primary/secondary action buttons on timer screens.
const kTimerButtonMaxWidth = 200.0;

const kTimerButtonRowGap = 12.0;

const kTimerStagePadding = EdgeInsets.fromLTRB(24, 16, 24, 24);

/// Minimum height for the top and bottom stage rows.
const kTimerStageRowMinHeight = 100.0;

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

/// Full-height timer stage: top and bottom rows min 100 px, visual takes leftover.
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
    return LayoutBuilder(
      builder: (context, constraints) {
        final visualSlot = ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: kAppContentMaxWidth),
          child: visual,
        );
        final top = _TimerStageRow(child: header);
        final bottom = _TimerStageRow(child: footer);

        if (!constraints.hasBoundedHeight) {
          return Padding(
            padding: kTimerStagePadding,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                top,
                Align(child: visualSlot),
                bottom,
              ],
            ),
          );
        }

        return Padding(
          padding: kTimerStagePadding,
          child: Column(
            children: [
              top,
              Expanded(child: Center(child: visualSlot)),
              bottom,
            ],
          ),
        );
      },
    );
  }
}

class _TimerStageRow extends StatelessWidget {
  const _TimerStageRow({this.child});

  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(
        minHeight: kTimerStageRowMinHeight,
        minWidth: double.infinity,
      ),
      child: Center(child: child),
    );
  }
}
