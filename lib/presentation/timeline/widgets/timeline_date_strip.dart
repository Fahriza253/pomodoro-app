import 'package:flutter/material.dart';
import 'package:pomodoro_app/presentation/shared/format_helpers.dart';

/// Horizontal day strip for one month — free scroll, tap to select.
class TimelineDateStrip extends StatefulWidget {
  const TimelineDateStrip({
    required this.dates,
    required this.selectedDate,
    required this.onSelected,
    super.key,
  });

  final List<DateTime> dates;
  final DateTime selectedDate;
  final ValueChanged<DateTime> onSelected;

  @override
  State<TimelineDateStrip> createState() => _TimelineDateStripState();
}

class _TimelineDateStripState extends State<TimelineDateStrip> {
  final _controller = ScrollController();
  static const _itemWidth = 56.0;
  static const _gap = 8.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToSelected());
  }

  @override
  void didUpdateWidget(covariant TimelineDateStrip oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!isSameDay(oldWidget.selectedDate, widget.selectedDate) ||
        oldWidget.dates != widget.dates) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToSelected());
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _scrollToSelected() {
    if (!_controller.hasClients || widget.dates.isEmpty) {
      return;
    }
    final index = widget.dates
        .indexWhere((d) => isSameDay(d, widget.selectedDate))
        .clamp(0, widget.dates.length - 1);
    final target = index * (_itemWidth + _gap) - 48;
    _controller.animateTo(
      target.clamp(0.0, _controller.position.maxScrollExtent),
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.dates.isEmpty) {
      return const SizedBox.shrink();
    }
    final scheme = Theme.of(context).colorScheme;
    final languageCode = Localizations.localeOf(context).languageCode;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: SizedBox(
        height: 72,
        child: ListView.separated(
          controller: _controller,
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: widget.dates.length,
          separatorBuilder: (_, _) => const SizedBox(width: _gap),
          itemBuilder: (context, index) {
            final date = widget.dates[index];
            final selected = isSameDay(date, widget.selectedDate);
            return Material(
              color: selected ? scheme.primary : scheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(16),
              child: InkWell(
                onTap: () => widget.onSelected(date),
                borderRadius: BorderRadius.circular(16),
                child: SizedBox(
                  width: _itemWidth,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        formatWeekdayShort(date, languageCode),
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: selected
                              ? scheme.onPrimary
                              : scheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${date.day}',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: selected
                                  ? scheme.onPrimary
                                  : scheme.onSurface,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
