/// Catalog of in-app alert tone identifiers and bundled asset paths.
class AlertToneCatalog {
  const AlertToneCatalog._();

  static const String successArpeggio = 'success_arpeggio';
  static const String breakCoin = 'break_coin';
  static const String failureWrong = 'failure_wrong';

  static const String defaultFocusSuccess = successArpeggio;
  static const String defaultBreakOver = breakCoin;
  static const String defaultFocusFailure = failureWrong;

  /// Shared between focus-success and break-over categories.
  static const Set<String> sharedSegmentToneIds = {successArpeggio, breakCoin};

  static const Set<String> focusFailureToneIds = {failureWrong};

  static String assetPath(String toneId) => switch (toneId) {
    successArpeggio => 'assets/audios/djm62_successarpeggio.wav',
    breakCoin => 'assets/audios/xupr_e3_mixkit_arcade_game_jump_coin_216.wav',
    failureWrong => 'assets/audios/gabrielaraujo_failurewrong_action.wav',
    _ => throw ArgumentError('Unknown alert tone: $toneId'),
  };

  /// Android `res/raw` resource name (no extension).
  static String androidRawName(String toneId) => switch (toneId) {
    successArpeggio => 'success_arpeggio',
    breakCoin => 'break_coin',
    failureWrong => 'failure_wrong',
    _ => throw ArgumentError('Unknown alert tone: $toneId'),
  };

  /// iOS bundle sound filename (with extension).
  static String iosBundleSound(String toneId) =>
      '${androidRawName(toneId)}.wav';

  static String label(String toneId) => switch (toneId) {
    successArpeggio => 'Success Arpeggio',
    breakCoin => 'Arcade Coin',
    failureWrong => 'Failure Alert',
    _ => toneId,
  };

  static bool isValidFocusSuccess(String toneId) =>
      sharedSegmentToneIds.contains(toneId);

  static bool isValidBreakOver(String toneId) =>
      sharedSegmentToneIds.contains(toneId);

  static bool isValidFocusFailure(String toneId) =>
      focusFailureToneIds.contains(toneId);
}
