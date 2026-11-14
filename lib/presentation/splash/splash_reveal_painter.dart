import 'package:flutter/material.dart';

import 'package:pomodoro_app/presentation/splash/circle_reveal_clipper.dart';

/// Paints ripple rings and a tinted overlay with a center hole (no [ClipPath]).
class SplashRevealPainter extends CustomPainter {
  SplashRevealPainter({
    required this.reveal,
    required this.origin,
    required this.overlayColor,
    required this.ringColor,
    required this.edgeColor,
  });

  final double reveal;
  final Offset origin;
  final Color overlayColor;
  final Color ringColor;
  final Color edgeColor;

  static const _ringCount = 3;
  static const _stagger = 0.12;

  @override
  void paint(Canvas canvas, Size size) {
    if (reveal <= 0) {
      return;
    }

    _paintRipples(canvas, size);

    final maxRadius = CircleRevealClipper.maxRadius(size, origin);
    final eased = Curves.easeInOutCubic.transform(reveal);
    final holeRadius = eased * maxRadius;

    _paintOverlay(canvas, size, holeRadius);

    if (holeRadius > 0) {
      final edgePaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.5
        ..color = edgeColor.withValues(alpha: 0.65);
      canvas.drawCircle(origin, holeRadius, edgePaint);
    }
  }

  void _paintRipples(Canvas canvas, Size size) {
    final maxRadius = CircleRevealClipper.maxRadius(size, origin);

    for (var i = 0; i < _ringCount; i++) {
      final start = i * _stagger;
      final local = ((reveal - start) / (1 - start)).clamp(0.0, 1.0);
      if (local <= 0) {
        continue;
      }

      final eased = Curves.easeOut.transform(local);
      final radius = eased * maxRadius;
      final opacity = (1 - eased) * 0.55;
      if (opacity <= 0) {
        continue;
      }

      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5 + (1 - eased) * 4
        ..color = ringColor.withValues(alpha: opacity);
      canvas.drawCircle(origin, radius, paint);
    }
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
        oldDelegate.overlayColor != overlayColor ||
        oldDelegate.ringColor != ringColor ||
        oldDelegate.edgeColor != edgeColor;
  }
}