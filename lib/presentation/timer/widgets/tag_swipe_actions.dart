import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Fraction of [maxExtent] at which a swipe snaps open on release.
@visibleForTesting
const kTagSwipeOpenFraction = 0.4;

/// Maps a horizontal drag into a 0…[maxExtent] reveal (opens toward the start edge).
@visibleForTesting
double clampTagSwipeExtent({
  required double current,
  required double deltaDx,
  required double maxExtent,
  required bool isRtl,
}) {
  if (maxExtent <= 0) {
    return 0;
  }
  final openDelta = isRtl ? deltaDx : -deltaDx;
  return (current + openDelta).clamp(0.0, maxExtent);
}

@visibleForTesting
bool tagSwipeShouldSnapOpen(double extent, double maxExtent) {
  if (maxExtent <= 0) {
    return false;
  }
  return extent >= maxExtent * kTagSwipeOpenFraction;
}

/// Foreground slide that reveals trailing actions. Pointer owns the extent;
/// snap uses cubic easing (no spring).
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
  final Widget actions;
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
  Animation<double>? _snapAnimation;
  double _extent = 0;
  bool _armedHaptic = false;

  @override
  void initState() {
    super.initState();
    _extent = widget.isOpen ? widget.actionsWidth : 0;
    _snapController =
        AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 220),
        )..addListener(() {
          final anim = _snapAnimation;
          if (anim == null) {
            return;
          }
          setState(() => _extent = anim.value);
        });
  }

  @override
  void didUpdateWidget(TagSwipeActions oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.actionsWidth != oldWidget.actionsWidth) {
      _extent = _extent.clamp(0.0, widget.actionsWidth);
    }
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
      _extent = clampTagSwipeExtent(
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
    final open = tagSwipeShouldSnapOpen(_extent, widget.actionsWidth);
    widget.onOpenChanged(open);
    _snapTo(open ? widget.actionsWidth : 0);
  }

  void _onDragCancel() {
    widget.onOpenChanged(false);
    _snapTo(0);
  }

  void _snapTo(double target) {
    final reduced = MediaQuery.disableAnimationsOf(context);
    if (reduced) {
      _snapController.stop();
      setState(() => _extent = target);
      return;
    }
    _snapAnimation = Tween<double>(begin: _extent, end: target).animate(
      CurvedAnimation(parent: _snapController, curve: Curves.easeOutCubic),
    );
    _snapController
      ..reset()
      ..forward();
  }

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final dx = isRtl ? _extent : -_extent;

    return ClipRect(
      child: Stack(
        alignment: AlignmentDirectional.centerEnd,
        children: [
          IgnorePointer(
            ignoring: _extent < 8,
            child: ExcludeSemantics(
              excluding: _extent < widget.actionsWidth * kTagSwipeOpenFraction,
              child: widget.actions,
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
