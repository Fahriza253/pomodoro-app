import 'package:flutter/material.dart';
import 'package:pomodoro_app/presentation/shared/color_helpers.dart';

/// Small filled circle showing a tag's hex color.
class TagColorDot extends StatelessWidget {
  const TagColorDot({
    required this.hex,
    this.size = 10,
    this.fallback = const Color(0xFF9CA3AF),
    super.key,
  });

  final String hex;
  final double size;
  final Color fallback;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: parseHexColorOr(hex, fallback),
        shape: BoxShape.circle,
      ),
    );
  }
}
