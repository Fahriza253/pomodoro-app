import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:pomodoro_app/presentation/shared/app_layout.dart';
import 'package:pomodoro_app/presentation/shared/fluid_overscroll.dart';

const _kBarrierMaxOpacity = 0.45;
const _kDismissFraction = 0.5;

typedef FluidSheetBuilder<T> =
    Widget Function(BuildContext context, void Function(T? result) close);

/// Opens a bottom sheet with fluid overscroll: pinned rest edge, rubber-band
/// height past open, critically damped settle. Result is delivered after close.
Future<T?> showFluidBottomSheet<T>(
  BuildContext context, {
  required FluidSheetBuilder<T> builder,
  String barrierLabel = 'Dismiss',
}) {
  return Navigator.of(
    context,
  ).push<T>(_FluidSheetRoute<T>(builder: builder, barrierLabel: barrierLabel));
}

/// Title plus expanding [child] with the same insets as Select a tag.
class FluidSheetColumn extends StatelessWidget {
  const FluidSheetColumn({required this.title, required this.child, super.key});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: 8 + bottomInset),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
            child: Text(title, style: Theme.of(context).textTheme.titleLarge),
          ),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _FluidSheetRoute<T> extends PopupRoute<T> {
  _FluidSheetRoute({required this.builder, required this.barrierLabel});

  final FluidSheetBuilder<T> builder;

  @override
  final String barrierLabel;

  @override
  bool get opaque => false;

  @override
  bool get barrierDismissible => false;

  @override
  Color? get barrierColor => Colors.transparent;

  @override
  Duration get transitionDuration => Duration.zero;

  @override
  Duration get reverseTransitionDuration => Duration.zero;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return SizedBox.expand(child: _FluidSheetHost<T>(builder: builder));
  }
}

class _FluidSheetHost<T> extends StatefulWidget {
  const _FluidSheetHost({required this.builder});

  final FluidSheetBuilder<T> builder;

  @override
  State<_FluidSheetHost<T>> createState() => _FluidSheetHostState<T>();
}

class _FluidSheetHostState<T> extends State<_FluidSheetHost<T>>
    with SingleTickerProviderStateMixin {
  late final AnimationController _snap;
  Widget? _body;
  double _progress = 0;
  double _velocity = 0;
  double _availableHeight = 1;
  bool _closing = false;
  T? _result;

  double get _restHeight => _availableHeight * kFluidSheetMinHeightFraction;

  @override
  void initState() {
    super.initState();
    _snap = AnimationController.unbounded(vsync: this)
      ..addListener(() {
        setState(() => _progress = _snap.value);
      })
      ..addStatusListener(_onSnapStatus);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      unawaited(_animateTo(1));
    });
  }

  @override
  void dispose() {
    _snap.dispose();
    super.dispose();
  }

  void _onSnapStatus(AnimationStatus status) {
    if (status != AnimationStatus.completed) {
      return;
    }
    if (_closing && _progress <= 0.001 && mounted) {
      Navigator.of(context).pop(_result);
    }
  }

  Future<void> _animateTo(double target) async {
    if (!mounted) {
      return;
    }
    final reduced = MediaQuery.disableAnimationsOf(context);
    _snap.stop();
    if (reduced) {
      setState(() => _progress = target);
      _velocity = 0;
      if (_closing && target == 0 && mounted) {
        Navigator.of(context).pop(_result);
      }
      return;
    }
    final simulation = SpringSimulation(
      kFluidSettleSpring,
      _progress,
      target,
      _velocity,
    );
    _velocity = 0;
    await _snap.animateWith(simulation);
  }

  void _close(T? result) {
    if (_closing) {
      return;
    }
    _closing = true;
    _result = result;
    unawaited(_animateTo(0));
  }

  void _onHandleDragStart(DragStartDetails details) {
    _snap.stop();
    _closing = false;
  }

  void _onHandleDragUpdate(DragUpdateDetails details) {
    _snap.stop();
    setState(() {
      _progress = fluidSheetLinearProgressFromDrag(
        current: _progress,
        deltaDy: details.primaryDelta ?? details.delta.dy,
        sheetHeight: _restHeight,
      );
    });
  }

  void _onHandleDragEnd(DragEndDetails details) {
    final restH = _restHeight <= 0 ? 1.0 : _restHeight;
    _velocity = -details.velocity.pixelsPerSecond.dy / restH;
    if (_progress < _kDismissFraction) {
      _close(null);
      return;
    }
    _closing = false;
    unawaited(_animateTo(1));
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final barrierT = _progress.clamp(0.0, 1.0);
    _body ??= widget.builder(context, _close);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) {
          return;
        }
        _close(null);
      },
      child: IgnorePointer(
        ignoring: _progress <= 0,
        child: LayoutBuilder(
          builder: (context, constraints) {
            _availableHeight = constraints.maxHeight;
            final restH = _restHeight;
            final height = tagSelectSheetDisplayHeight(
              linearProgress: _progress,
              restHeight: restH,
              availableHeight: _availableHeight,
            );
            final dy = tagSelectSheetTranslationY(
              linearProgress: _progress,
              sheetHeight: restH,
              viewportHeight: _availableHeight,
            );
            final width = constraints.maxWidth < kAppContentMaxWidth
                ? constraints.maxWidth
                : kAppContentMaxWidth;

            return Stack(
              fit: StackFit.expand,
              clipBehavior: Clip.none,
              children: [
                Positioned.fill(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => _close(null),
                    child: ColoredBox(
                      color: Colors.black.withValues(
                        alpha: _kBarrierMaxOpacity * barrierT,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: -dy,
                  height: height,
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: SizedBox(
                      width: width,
                      height: height,
                      child: Material(
                        color: scheme.surfaceContainerLow,
                        clipBehavior: Clip.antiAlias,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(28),
                        ),
                        child: Column(
                          children: [
                            _FluidSheetHandle(
                              onDragStart: _onHandleDragStart,
                              onDragUpdate: _onHandleDragUpdate,
                              onDragEnd: _onHandleDragEnd,
                              onDragCancel: () =>
                                  _onHandleDragEnd(DragEndDetails()),
                            ),
                            Expanded(child: _body!),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _FluidSheetHandle extends StatelessWidget {
  const _FluidSheetHandle({
    required this.onDragStart,
    required this.onDragUpdate,
    required this.onDragEnd,
    required this.onDragCancel,
  });

  final GestureDragStartCallback onDragStart;
  final GestureDragUpdateCallback onDragUpdate;
  final GestureDragEndCallback onDragEnd;
  final GestureDragCancelCallback onDragCancel;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onVerticalDragStart: onDragStart,
      onVerticalDragUpdate: onDragUpdate,
      onVerticalDragEnd: onDragEnd,
      onVerticalDragCancel: onDragCancel,
      child: SizedBox(
        height: 28,
        width: double.infinity,
        child: Center(
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: scheme.onSurfaceVariant.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(2),
            ),
            child: const SizedBox(width: 32, height: 4),
          ),
        ),
      ),
    );
  }
}
