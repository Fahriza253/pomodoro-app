import 'package:pomodoro_app/domain/settings/alert_tone_catalog.dart';
import 'package:test/test.dart';

void main() {
  group('AlertToneCatalog platform sound names', () {
    test('android raw names are lowercase resource-safe', () {
      for (final id in {
        ...AlertToneCatalog.sharedSegmentToneIds,
        ...AlertToneCatalog.focusFailureToneIds,
      }) {
        final raw = AlertToneCatalog.androidRawName(id);
        expect(raw, matches(RegExp(r'^[a-z0-9_]+$')));
        expect(raw.contains('.'), isFalse);
      }
    });

    test('ios bundle sounds use .wav extension', () {
      expect(
        AlertToneCatalog.iosBundleSound(AlertToneCatalog.successArpeggio),
        'success_arpeggio.wav',
      );
      expect(
        AlertToneCatalog.iosBundleSound(AlertToneCatalog.breakCoin),
        'break_coin.wav',
      );
      expect(
        AlertToneCatalog.iosBundleSound(AlertToneCatalog.failureWrong),
        'failure_wrong.wav',
      );
    });
  });
}
