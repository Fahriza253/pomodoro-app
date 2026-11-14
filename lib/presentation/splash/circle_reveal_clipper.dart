import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Clips away an expanding circle from [origin], revealing content beneath.
class CircleRevealClipper extends CustomClipper<Path> {
  CircleRevealClipper({
    required this.reveal,
    required this.origin,
  });

  /// `0` = full layer visible; `1` = circle covers the layer.
  final double reveal;
  final Offset origin;

  static double maxRadius(Size size, Offset origin) {
    final corners = <Offset>[
      Offset.zero,
      Offset(size.width, 0),
      Offset(0, size.height),
      Offset(size.width, size.height),
    ];
    var maxDistance = 0.0;
    for (final corner in corners) {
      maxDistance = math.max(maxDistance, (corner - origin).distance);
    }
    return maxDistance + 1;
  }

  @override
  Path getClip(Size size) {
    final bounds = Offset.zero & size;
    final full = Path()..addRect(bounds);
    if (reveal <= 0) {
      return full;
    }
    if (reveal >= 1) {
      return Path();
    }

    final radius = reveal * maxRadius(size, origin);
    final hole = Path()
      ..addOval(Rect.fromCircle(center: origin, radius: radius));
    return Path.combine(PathOperation.difference, full, hole);
  }

  @override
  bool shouldReclip(CircleRevealClipper oldClipper) {
    return oldClipper.reveal != reveal || oldClipper.origin != origin;
  }

}