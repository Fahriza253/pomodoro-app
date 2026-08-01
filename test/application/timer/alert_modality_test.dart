import 'package:pomodoro_app/application/timer/alert_modality.dart';
import 'package:test/test.dart';

void main() {
  group('planAlertModalities', () {
    test('foreground unmuted: in-app sound + haptic', () {
      final plan = planAlertModalities(
        foreground: true,
        soundMuted: false,
        hapticEnabled: true,
        flashEnabled: false,
        flashCapable: false,
      );
      expect(plan.playInAppSound, isTrue);
      expect(plan.triggerHaptic, isTrue);
      expect(plan.triggerFlash, isFalse);
      expect(plan.osNotificationPlaySound, isTrue);
    });

    test('foreground muted: no in-app sound; OS would be silent if shown', () {
      final plan = planAlertModalities(
        foreground: true,
        soundMuted: true,
        hapticEnabled: true,
        flashEnabled: true,
        flashCapable: true,
      );
      expect(plan.playInAppSound, isFalse);
      expect(plan.triggerHaptic, isTrue);
      expect(plan.triggerFlash, isTrue);
      expect(plan.osNotificationPlaySound, isFalse);
    });

    test('background: OS sound follows mute; no in-app haptic/flash', () {
      final plan = planAlertModalities(
        foreground: false,
        soundMuted: true,
        hapticEnabled: true,
        flashEnabled: true,
        flashCapable: true,
      );
      expect(plan.playInAppSound, isFalse);
      expect(plan.triggerHaptic, isFalse);
      expect(plan.triggerFlash, isFalse);
      expect(plan.osNotificationPlaySound, isFalse);
    });

    test('flash only when enabled, capable, and foreground', () {
      expect(
        planAlertModalities(
          foreground: true,
          soundMuted: false,
          hapticEnabled: false,
          flashEnabled: true,
          flashCapable: false,
        ).triggerFlash,
        isFalse,
      );
      expect(
        planAlertModalities(
          foreground: false,
          soundMuted: false,
          hapticEnabled: false,
          flashEnabled: true,
          flashCapable: true,
        ).triggerFlash,
        isFalse,
      );
    });
  });
}
