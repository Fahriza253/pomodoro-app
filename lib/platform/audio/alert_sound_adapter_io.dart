import 'package:audioplayers/audioplayers.dart';
import 'package:pomodoro_app/domain/settings/alert_tone_catalog.dart';
import 'package:pomodoro_app/platform/audio/alert_sound_adapter.dart';

AlertSoundAdapter createAlertSoundAdapter() => AudioplayersAlertSoundAdapter();

class AudioplayersAlertSoundAdapter implements AlertSoundAdapter {
  AudioplayersAlertSoundAdapter() : _player = AudioPlayer() {
    // Notification-style playback so tones are audible while the app is open
    // (and not ducked/silenced by the default media context).
    _ready = _configure();
  }

  final AudioPlayer _player;
  late final Future<void> _ready;
  bool _disposed = false;

  Future<void> _configure() async {
    await _player.setPlayerMode(PlayerMode.lowLatency);
    await _player.setReleaseMode(ReleaseMode.stop);
    await _player.setVolume(1);
    await _player.setAudioContext(
      AudioContext(
        android: const AudioContextAndroid(
          isSpeakerphoneOn: false,
          stayAwake: false,
          contentType: AndroidContentType.sonification,
          usageType: AndroidUsageType.notificationEvent,
          audioFocus: AndroidAudioFocus.gainTransientMayDuck,
        ),
        iOS: AudioContextIOS(
          category: AVAudioSessionCategory.playback,
          options: const {
            AVAudioSessionOptions.mixWithOthers,
            AVAudioSessionOptions.duckOthers,
          },
        ),
      ),
    );
  }

  @override
  Future<void> play(String toneId) async {
    if (_disposed) {
      return;
    }
    try {
      await _ready;
      final source = AlertToneCatalog.assetPath(
        toneId,
      ).replaceFirst('assets/', '');
      await _player.stop();
      await _player.play(AssetSource(source));
    } catch (_) {
      // ponytail: never break timer flow if a tone fails to load/play
    }
  }

  @override
  void dispose() {
    if (_disposed) {
      return;
    }
    _disposed = true;
    _player.dispose();
  }
}
