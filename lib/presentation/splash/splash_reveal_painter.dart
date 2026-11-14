import 'package:flutter/material.dart';

import 'package:pomodoro_app/presentation/splash/circle_reveal_clipper.dart';

/// Tinted overlay with a center hole and no stroke or ripple rings.
class SplashRevealPainter extends CustomPainter {
  SplashRevealPainter({
    required this.reveal,
    required this.origin,
    required this.overlayColor,
  });

  final double reveal;
  final Offset origin;
  final Color overlayColor;

  @override
  void paint(Canvas canvas, Size size) {
    final maxRadius = CircleRevealClipper.maxRadius(size, origin);
    final holeRadius = reveal.clamp(0.0, 1.0) * maxRadius;
    _paintOverlay(canvas, size, holeRadius);
  }

  void _paintOverlay(Canvas canvas, Size size, double holeRadius) {
    final bounds = Offset.zero & size;
    if (holeRadius <= 0) {
      canvas.drawRect(bounds, Paint()..color = overlayColor);
      return;
    }

    final path = Path()
      ..fillType = PathFillType.evenOdd
      ..addRect(bounds)
      ..addOval(Rect.fromCircle(center: origin, radius: holeRadius));
    canvas.drawPath(path, Paint()..color = overlayColor);
  }

  @override
  bool shouldRepaint(SplashRevealPainter oldDelegate) {
    return oldDelegate.reveal != reveal ||
        oldDelegate.origin != origin ||
        oldDelegate.overlayColor != overlayColor;
  }
}
