/// Formats seconds for timer display (MM:SS or HH:MM:SS).
String formatTimerSeconds(int seconds, {bool forceHours = false}) {
  final safe = seconds < 0 ? 0 : seconds;
  final h = safe ~/ 3600;
  final m = (safe % 3600) ~/ 60;
  final s = safe % 60;
  if (forceHours || h > 0) {
    return '${h.toString().padLeft(2, '0')}:'
        '${m.toString().padLeft(2, '0')}:'
        '${s.toString().padLeft(2, '0')}';
  }
  return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
}

/// Preview label for idle Pomodoro from focus duration seconds.
String formatFocusPreview(int focusDurationSec) =>
    formatTimerSeconds(focusDurationSec);
