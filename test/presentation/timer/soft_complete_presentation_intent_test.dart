import 'dart:math';

import 'package:flutter_test/flutter_test.dart' hide EnginePhase;
import 'package:pomodoro_app/application/timer/timer_view_state.dart';
import 'package:pomodoro_app/domain/common/enums.dart';
import 'package:pomodoro_app/l10n/app_localizations_en.dart';
import 'package:pomodoro_app/l10n/app_localizations_id.dart';
import 'package:pomodoro_app/presentation/timer/soft_complete_presentation_intent.dart';

class _FixedRandom implements Random {
  _FixedRandom(this.value);
  final int value;

  @override
  int nextInt(int max) => value % max;

  @override
  bool nextBool() => throw UnimplementedError();

  @override
  double nextDouble() => throw UnimplementedError();
}

void main() {
  final en = AppLocalizationsEn();

  TimerViewState pomodoroView() => const TimerViewState(
        phase: EnginePhase.sessionComplete,
        mode: TimerMode.pomodoro,
        displaySec: 0,
        isCountdown: true,
      );

  group('SoftCompletePresentationIntent', () {
    test('Pomodoro present returns celebration with held body and wire targets',
        () {
      final intent = SoftCompletePresentationIntent(random: _FixedRandom(0));
      final screen = intent.present(
        view: pomodoroView(),
        l10n: en,
        languageCode: 'en',
      );

      expect(screen, isA<SoftCompleteCelebration>());
      final celebration = screen as SoftCompleteCelebration;
      expect(celebration.lottieAsset, 'assets/lottie/winner.json');
      expect(celebration.headline, 'You did it!');
      expect(
        celebration.body,
        'Nice work — session done! Keep going or take a breather?',
      );
      expect(celebration.primary.label, 'Start New Session');
      expect(
        celebration.primary.wire,
        SoftCompleteWireTarget.restartSameTag,
      );
      expect(celebration.secondary.label, 'Back to Home');
      expect(
        celebration.secondary.wire,
        SoftCompleteWireTarget.dismissSessionComplete,
      );
    });

    test('Pomodoro body index is held across present calls', () {
      final intent = SoftCompletePresentationIntent(random: _FixedRandom(1));
      final first = intent.present(
        view: pomodoroView(),
        l10n: en,
        languageCode: 'en',
      ) as SoftCompleteCelebration;
      final second = intent.present(
        view: pomodoroView(),
        l10n: en,
        languageCode: 'en',
      ) as SoftCompleteCelebration;

      expect(first.body, second.body);
      expect(first.body, 'Session done! Keep going or rest a bit?');
    });

    test('Pomodoro maps all three body tones', () {
      for (final (index, expected) in [
        (0, 'Nice work — session done! Keep going or take a breather?'),
        (1, 'Session done! Keep going or rest a bit?'),
        (2, 'Great job! Keep your rhythm or rest first?'),
      ]) {
        final screen = SoftCompletePresentationIntent(random: _FixedRandom(index))
            .present(view: pomodoroView(), l10n: en, languageCode: 'en')
            as SoftCompleteCelebration;
        expect(screen.body, expected);
      }
    });

    test('same body index yields ID celebration packet', () {
      final id = AppLocalizationsId();
      SoftCompleteCelebration celebrate(int index) =>
          SoftCompletePresentationIntent(random: _FixedRandom(index)).present(
            view: pomodoroView(),
            l10n: id,
            languageCode: 'id',
          ) as SoftCompleteCelebration;

      expect(celebrate(0).headline, 'Berhasil!');
      expect(
        celebrate(0).body,
        'Keren, sesi ini selesai! Mau lanjut atau istirahat dulu?',
      );
      expect(
        celebrate(1).body,
        'Sesi selesai! Tetap lanjut atau istirahat sebentar?',
      );
      expect(
        celebrate(2).body,
        'Kerja bagus! Jaga ritmemu atau istirahat dulu?',
      );
    });

    test('Flexible present returns simple chrome with segment summary', () {
      final view = TimerViewState(
        phase: EnginePhase.sessionComplete,
        mode: TimerMode.flexible,
        displaySec: 3661,
        isCountdown: false,
        segmentEndFinishedType: SegmentType.flexible,
        segmentEndCompletedCount: 1,
        segmentEndTotalCount: 1,
      );
      final screen = SoftCompletePresentationIntent().present(
        view: view,
        l10n: en,
        languageCode: 'en',
      );

      expect(screen, isA<SoftCompleteSimple>());
      final simple = screen as SoftCompleteSimple;
      expect(simple.headline, 'Session complete');
      expect(simple.segmentEndBody, isNotNull);
      expect(simple.savedLine, contains('Session saved'));
      expect(simple.durationLine, 'Active: 01:01:01');
      expect(simple.primary.label, 'START AGAIN');
      expect(simple.primary.wire, SoftCompleteWireTarget.restartSameTag);
      expect(simple.secondary.label, 'DONE');
      expect(
        simple.secondary.wire,
        SoftCompleteWireTarget.dismissSessionComplete,
      );
    });

    test('Flexible without segment summary falls back on title', () {
      final view = const TimerViewState(
        phase: EnginePhase.sessionComplete,
        mode: TimerMode.flexible,
        displaySec: 60,
        isCountdown: false,
      );
      final simple = SoftCompletePresentationIntent().present(
        view: view,
        l10n: en,
        languageCode: 'en',
      ) as SoftCompleteSimple;

      expect(simple.headline, 'Session complete');
      expect(simple.segmentEndBody, isNull);
      expect(simple.durationLine, 'Active: 00:01:00');
    });
  });
}
