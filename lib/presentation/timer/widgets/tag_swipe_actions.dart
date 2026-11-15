import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/services.dart';
import 'package:pomodoro_app/presentation/shared/fluid_overscroll.dart';

/// Fraction of [maxExtent] at which a swipe snaps open on release.
@visibleForTesting
const kTagSwipeOpenFraction = 0.4;

/// Maps a horizontal drag into a linear reveal that may exceed [maxExtent].
@visibleForTesting
double tagSwipeLinearExtent({
  required double current,
  required double deltaDx,
  required double maxExtent,
  required bool isRtl,
}) {
  if (maxExtent <= 0) {
    return 0;
  }
  final openDelta = isRtl ? deltaDx : -deltaDx;
  final next = current + openDelta;
  return next < 0 ? 0.0 : next;
}

@visibleForTesting
double tagSwipeVisualExtent(double linear, double maxExtent) {
  return fluidVisualOverscroll(linear, min: 0, max: maxExtent);
}

@visibleForTesting
bool tagSwipeShouldSnapOpen(double extent, double maxExtent) {
  if (maxExtent <= 0) {
    return false;
  }
  return extent >= maxExtent * kTagSwipeOpenFraction;
}

typedef TagSwipeActionsBuilder =
    Widget Function(BuildContext context, double revealT);

/// Foreground slide that reveals trailing actions. Pointer owns the linear
/// extent, including pull past fully open. Settle uses a critically damped
/// spring. [actions] receives reveal 0…1 (full size at rest open; overshoot
/// does not grow chrome past 1).
class TagSwipeActions extends StatefulWidget {
  const TagSwipeActions({
    required this.actionsWidth,
    required this.actions,
    required this.child,
    required this.isOpen,
    required this.onOpenChanged,
    this.onExclusiveDragStart,
    super.key,
  });

  final double actionsWidth;
  final TagSwipeActionsBuilder actions;
  final Widget child;
  final bool isOpen;
  final ValueChanged<bool> onOpenChanged;
  final VoidCallback? onExclusiveDragStart;

  @override
  State<TagSwipeActions> createState() => _TagSwipeActionsState();
}

class _TagSwipeActionsState extends State<TagSwipeActions>
    with SingleTickerProviderStateMixin {
  late final AnimationController _snapController;
  double _extent = 0;
  double _velocity = 0;
  bool _armedHaptic = false;

  @override
  void initState() {
    super.initState();
    _extent = widget.isOpen ? widget.actionsWidth : 0;
    _snapController = AnimationController.unbounded(vsync: this)
      ..addListener(() {
        setState(() => _extent = _snapController.value);
      });
  }

  @override
  void didUpdateWidget(TagSwipeActions oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.isOpen && oldWidget.isOpen) {
      _snapTo(0);
    }
  }

  @override
  void dispose() {
    _snapController.dispose();
    super.dispose();
  }

  void _onDragStart(DragStartDetails details) {
    _snapController.stop();
    widget.onExclusiveDragStart?.call();
  }

  void _onDragUpdate(DragUpdateDetails details) {
    _snapController.stop();
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    setState(() {
      _extent = tagSwipeLinearExtent(
        current: _extent,
        deltaDx: details.delta.dx,
        maxExtent: widget.actionsWidth,
        isRtl: isRtl,
      );
      final armed = tagSwipeShouldSnapOpen(_extent, widget.actionsWidth);
      if (armed && !_armedHaptic) {
        _armedHaptic = true;
        HapticFeedback.selectionClick();
      } else if (!armed) {
        _armedHaptic = false;
      }
    });
  }

  void _onDragEnd(DragEndDetails details) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final vx = details.velocity.pixelsPerSecond.dx;
    _velocity = isRtl ? vx : -vx;
    final open = tagSwipeShouldSnapOpen(_extent, widget.actionsWidth);
    widget.onOpenChanged(open);
    _snapTo(open ? widget.actionsWidth : 0);
  }

  void _onDragCancel() {
    widget.onOpenChanged(false);
    _velocity = 0;
    _snapTo(0);
  }

  void _snapTo(double target) {
    final reduced = MediaQuery.disableAnimationsOf(context);
    _snapController.stop();
    if (reduced) {
      setState(() => _extent = target);
      _velocity = 0;
      return;
    }
    final simulation = SpringSimulation(
      kFluidSettleSpring,
      _extent,
      target,
      _velocity,
    );
    _velocity = 0;
    _snapController.animateWith(simulation);
  }

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final maxExtent = widget.actionsWidth;
    final visual = tagSwipeVisualExtent(_extent, maxExtent);
    final revealT = maxExtent <= 0 ? 0.0 : (visual / maxExtent).clamp(0.0, 1.0);
    final dx = isRtl ? visual : -visual;

    return ClipRect(
      child: Stack(
        alignment: AlignmentDirectional.centerEnd,
        children: [
          IgnorePointer(
            ignoring: visual < 8,
            child: ExcludeSemantics(
              excluding: _extent < maxExtent * kTagSwipeOpenFraction,
              child: widget.actions(context, revealT),
            ),
          ),
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onHorizontalDragStart: _onDragStart,
            onHorizontalDragUpdate: _onDragUpdate,
            onHorizontalDragEnd: _onDragEnd,
            onHorizontalDragCancel: _onDragCancel,
            child: Transform.translate(
              offset: Offset(dx, 0),
              child: widget.child,
            ),
          ),
        ],
      ),
    );
  }
}
