import 'package:flutter/material.dart';
import 'package:pomodoro_app/presentation/l10n/l10n_extensions.dart';
import 'package:pomodoro_app/presentation/shared/format_helpers.dart';

class TimelineMonthFilter extends StatelessWidget {
  const TimelineMonthFilter({
    required this.selected,
    required this.options,
    required this.onSelected,
    super.key,
  });

  final DateTime selected;
  final List<DateTime> options;
  final ValueChanged<DateTime> onSelected;

  @override
  Widget build(BuildContext context) {
    final languageCode = Localizations.localeOf(context).languageCode;
    return PopupMenuButton<DateTime>(
      tooltip: context.l10n.filterMonthTooltip,
      initialValue: selected,
      onSelected: onSelected,
      itemBuilder: (context) => [
        for (final month in options)
          PopupMenuItem(
            value: month,
            child: Text(
              formatMonthYear(month, languageCode),
              style: TextStyle(
                fontWeight: isSameMonth(month, selected)
                    ? FontWeight.w700
                    : FontWeight.w400,
              ),
            ),
          ),
      ],
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              formatMonthYear(selected, languageCode),
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
            ),
            const Icon(Icons.arrow_drop_down),
          ],
        ),
      ),
    );
  }
}
