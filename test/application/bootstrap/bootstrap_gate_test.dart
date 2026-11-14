import 'package:flutter_test/flutter_test.dart';
import 'package:pomodoro_app/application/bootstrap/bootstrap_gate.dart';

void main() {
  group('BootstrapGate.phase', () {
    test('database error wins over beat and value', () {
      expect(
        BootstrapGate.phase(dbHasError: true, dbHasValue: true),
        BootstrapPhase.databaseError,
      );
    });

    test('splash when DB still loading', () {
      expect(
        BootstrapGate.phase(dbHasError: false, dbHasValue: false),
        BootstrapPhase.splash,
      );
    });

    test('ready when DB has value even if marketing beat is incomplete', () {
      expect(
        BootstrapGate.phase(dbHasError: false, dbHasValue: true),
        BootstrapPhase.ready,
      );
    });
  });
}
