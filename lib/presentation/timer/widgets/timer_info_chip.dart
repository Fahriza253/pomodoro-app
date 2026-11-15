import 'package:flutter/material.dart';

class TimerInfoChip extends StatelessWidget {
  const TimerInfoChip({
    required this.icon,
    required this.label,
    required this.iconColor,
    required this.background,
    required this.foreground,
    this.emphasized = false,
    this.maxWidth,
    super.key,
  });

  final IconData icon;
  final String label;
  final Color iconColor;
  final Color background;
  final Color foreground;

  /// Soft emphasis: heavier weight only, same icon and font size as other chips.
  final bool emphasized;
  final double? maxWidth;

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.labelLarge?.copyWith(
      color: foreground,
      fontWeight: emphasized ? FontWeight.w600 : FontWeight.w500,
    );

    final labelText = Text(
      label,
      style: textStyle,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      softWrap: false,
    );

    Widget chip = Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: iconColor),
          const SizedBox(width: 6),
          if (maxWidth != null) Flexible(child: labelText) else labelText,
        ],
      ),
    );

    if (maxWidth != null) {
      chip = ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth!),
        child: chip,
      );
    }

    return chip;
  }
}