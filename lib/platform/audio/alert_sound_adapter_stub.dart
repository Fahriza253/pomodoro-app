import 'package:pomodoro_app/platform/audio/alert_sound_adapter.dart';

AlertSoundAdapter createAlertSoundAdapter() => StubAlertSoundAdapter();

class StubAlertSoundAdapter implements AlertSoundAdapter {
  final List<String> played = [];

  @override
  Future<void> play(String toneId) async {
    played.add(toneId);
  }

  @override
  void dispose() {}
}
