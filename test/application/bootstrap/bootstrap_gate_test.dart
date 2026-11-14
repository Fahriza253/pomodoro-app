import 'package:flutter_test/flutter_test.dart';
import 'package:pomodoro_app/application/bootstrap/bootstrap_gate.dart';

void main() {
  group('BootstrapGate.phase', () {
    test('database error wins over beat and value', () {
      expect(
        BootstrapGate.phase(
          dbHasError: true,
          dbHasValue: true,
          marketingBeatComplete: true,
        ),
        BootstrapPhase.databaseError,
      );
    });

    test('splash when DB still loading', () {
      expect(
        BootstrapGate.phase(
          dbHasError: false,
          dbHasValue: false,
          marketingBeatComplete: true,
        ),
        BootstrapPhase.splash,
      );
    });

    test('splash when marketing beat incomplete', () {
      expect(
        BootstrapGate.phase(
          dbHasError: false,
          dbHasValue: true,
          marketingBeatComplete: false,
        ),
        BootstrapPhase.splash,
      );
    });

    test('ready when DB has value and beat complete', () {
      expect(
        BootstrapGate.phase(
          dbHasError: false,
          dbHasValue: true,
          marketingBeatComplete: true,
        ),
        BootstrapPhase.ready,
      );
    });
  });
}