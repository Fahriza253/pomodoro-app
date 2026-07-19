/// Plays bundled alert tones selected in Settings.
abstract class AlertSoundAdapter {
  Future<void> play(String toneId);

  void dispose();
}
