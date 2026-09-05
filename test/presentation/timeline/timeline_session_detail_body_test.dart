import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pomodoro_app/domain/common/enums.dart';
import 'package:pomodoro_app/domain/session/session.dart';
import 'package:pomodoro_app/domain/tag/config_snapshot.dart';
import 'package:pomodoro_app/domain/timeline/timeline_models.dart';
import 'package:pomodoro_app/l10n/app_localizations.dart';
import 'package:pomodoro_app/presentation/timeline/widgets/timeline_session_detail_body.dart';

SessionDetail _detail({
  required TimerMode mode,
  required int cyclesCompleted,
  int? cyclesTarget,
}) {
  return SessionDetail(
    session: Session(
      id: 's1',
      tagId: 't1',
      mode: mode,
      status: SessionStatus.completed,
      startedAtUtcMs: 1_000,
      endedAtUtcMs: 2_000,
      timelineDate: '2026-08-22',
      totalActiveSec: 100,
      totalPausedSec: 0,
      configSnapshot: ConfigSnapshot(mode: mode),
      pomodoroFocusCount: 0,
      pomodoroCyclesCompleted: cyclesCompleted,
      pomodoroCyclesTarget: cyclesTarget,
      createdAtUtcMs: 1,
      updatedAtUtcMs: 1,
    ),
    segments: const [],
    tagDisplayName: 'General',
    tagColor: '#9CA3AF',
  );
}

Future<void> _pumpBody(WidgetTester tester, SessionDetail detail) async {
  await tester.pumpWidget(
    MaterialApp(
      locale: const Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: TimelineSessionDetailBody(
          detail: detail,
          timeFormat: TimeFormat.h24,
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('Pomodoro detail shows Cycle X of Y from session fields', (
    tester,
  ) async {
    await _pumpBody(
      tester,
      _detail(mode: TimerMode.pomodoro, cyclesCompleted: 4, cyclesTarget: 4),
    );

    expect(find.text('Cycle 4 of 4'), findsOneWidget);
  });

  testWidgets('Pomodoro detail shows grown target after LANJUTKAN', (
    tester,
  ) async {
    await _pumpBody(
      tester,
      _detail(mode: TimerMode.pomodoro, cyclesCompleted: 8, cyclesTarget: 8),
    );

    expect(find.text('Cycle 8 of 8'), findsOneWidget);
  });

  testWidgets('Flexible detail has no cycle header', (tester) async {
    await _pumpBody(
      tester,
      _detail(mode: TimerMode.flexible, cyclesCompleted: 0),
    );

    expect(find.textContaining('Cycle'), findsNothing);
  });
}
