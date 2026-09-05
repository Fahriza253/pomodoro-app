import 'package:pomodoro_app/domain/tag/tag_config_validator.dart';
import 'package:pomodoro_app/domain/tag/tag_inputs.dart';
import 'package:test/test.dart';

void main() {
  const validator = TagConfigValidator();

  group('TagConfigValidator', () {
    test('rejects empty tag name', () {
      final result = validator.validateTagName('  ');
      expect(result.isValid, isFalse);
    });

    test('accepts valid pomodoro config', () {
      final result = validator.validatePomodoro(
        TagModeConfigPomodoro.defaults(),
      );
      expect(result.isValid, isTrue);
    });

    test('rejects totalCycles below 2', () {
      final result = validator.validatePomodoro(
        const TagModeConfigPomodoro(
          focusDurationSec: 1500,
          shortBreakDurationSec: 300,
          longBreakDurationSec: 900,
          sessionsBeforeLongBreak: 4,
          totalCycles: 1,
        ),
      );
      expect(result.isValid, isFalse);
    });

    test('rejects focus duration not on 5-min grid', () {
      final result = validator.validatePomodoro(
        const TagModeConfigPomodoro(
          focusDurationSec: 26 * 60,
          shortBreakDurationSec: 300,
          longBreakDurationSec: 900,
          sessionsBeforeLongBreak: 4,
          totalCycles: 4,
        ),
      );
      expect(result.isValid, isFalse);
    });

    test('rejects short break below minimum', () {
      final result = validator.validatePomodoro(
        const TagModeConfigPomodoro(
          focusDurationSec: 1500,
          shortBreakDurationSec: 4 * 60,
          longBreakDurationSec: 900,
          sessionsBeforeLongBreak: 4,
          totalCycles: 4,
        ),
      );
      expect(result.isValid, isFalse);
      expect(
        result.issues.single.message,
        'Istirahat pendek harus 5–15 menit (kelipatan 1).',
      );
    });

    test('rejects long break below minimum with honest bounds', () {
      final result = validator.validatePomodoro(
        const TagModeConfigPomodoro(
          focusDurationSec: 1500,
          shortBreakDurationSec: 300,
          longBreakDurationSec: 9 * 60,
          sessionsBeforeLongBreak: 4,
          totalCycles: 4,
        ),
      );
      expect(result.isValid, isFalse);
      expect(
        result.issues.single.message,
        'Istirahat panjang harus 10–30 menit (kelipatan 1).',
      );
    });

    test('rejects one focus before long break on Tag save', () {
      final result = validator.validatePomodoro(
        const TagModeConfigPomodoro(
          focusDurationSec: 1500,
          shortBreakDurationSec: 300,
          longBreakDurationSec: 900,
          sessionsBeforeLongBreak: 1,
          totalCycles: 4,
        ),
      );
      expect(result.isValid, isFalse);
      expect(
        result.issues.single.message,
        'Fokus sebelum istirahat panjang harus 2–10.',
      );
    });

    test('accepts pomodoro config at bounds', () {
      final result = validator.validatePomodoro(
        const TagModeConfigPomodoro(
          focusDurationSec: 180 * 60,
          shortBreakDurationSec: 10 * 60,
          longBreakDurationSec: 30 * 60,
          sessionsBeforeLongBreak: 10,
          totalCycles: 8,
        ),
      );
      expect(result.isValid, isTrue);
    });

    test('rejects flexible reminder without interval', () {
      final result = validator.validateFlexible(
        const TagModeConfigFlexible(
          reminderEnabled: true,
          reminderIntervalMin: 0,
        ),
      );
      expect(result.isValid, isFalse);
    });

    test('accepts open-ended flexible default duration', () {
      final result = validator.validateFlexible(
        const TagModeConfigFlexible(
          defaultDurationSec: null,
          reminderEnabled: true,
          reminderIntervalMin: 25,
        ),
      );
      expect(result.isValid, isTrue);
    });

    test('rejects flexible default duration off the focus grid', () {
      final result = validator.validateFlexible(
        const TagModeConfigFlexible(
          defaultDurationSec: 26 * 60,
          reminderEnabled: true,
          reminderIntervalMin: 25,
        ),
      );
      expect(result.isValid, isFalse);
      expect(
        result.issues.single.message,
        'Durasi default harus 5–180 menit (kelipatan 5).',
      );
    });

    test('rejects reminder interval off the reminder grid when enabled', () {
      final result = validator.validateFlexible(
        const TagModeConfigFlexible(
          reminderEnabled: true,
          reminderIntervalMin: 1,
        ),
      );
      expect(result.isValid, isFalse);
      expect(
        result.issues.single.message,
        'Interval pengingat harus 5–180 menit (kelipatan 5).',
      );
    });

    test('accepts disabled reminder even with zero interval', () {
      final result = validator.validateFlexible(
        const TagModeConfigFlexible(
          reminderEnabled: false,
          reminderIntervalMin: 0,
        ),
      );
      expect(result.isValid, isTrue);
    });
  });
}
