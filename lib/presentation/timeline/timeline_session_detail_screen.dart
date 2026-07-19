import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pomodoro_app/presentation/l10n/l10n_extensions.dart';
import 'package:pomodoro_app/presentation/timeline/timeline_providers.dart';
import 'package:pomodoro_app/presentation/timeline/widgets/timeline_session_detail_body.dart';

class TimelineSessionDetailScreen extends ConsumerWidget {
  const TimelineSessionDetailScreen({required this.sessionId, super.key});

  final String sessionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(sessionDetailProvider(sessionId));
    final timeFormat = ref.watch(timelineTimeFormatProvider);
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.sessionDetailTitle)),
      body: detailAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => Center(
          child: FilledButton(
            onPressed: () => ref.invalidate(sessionDetailProvider(sessionId)),
            child: Text(l10n.tryAgain),
          ),
        ),
        data: (detail) =>
            TimelineSessionDetailBody(detail: detail, timeFormat: timeFormat),
      ),
    );
  }
}
