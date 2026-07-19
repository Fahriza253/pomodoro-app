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
  });
}
