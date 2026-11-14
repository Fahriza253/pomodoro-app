/// Cold-start phase before the main shell (see `docs/design/pages/splash.md`).
enum BootstrapPhase {
  /// Local database open or seed failed; marketing beat skipped.
  databaseError,

  /// Waiting on `max(marketing beat, DB ready)`.
  splash,

  /// Main navigation may mount.
  ready,
}

/// Chooses the bootstrap phase from DB readiness and the marketing beat.
abstract final class BootstrapGate {
  static BootstrapPhase phase({
    required bool dbHasError,
    required bool dbHasValue,
    required bool marketingBeatComplete,
  }) {
    if (dbHasError) {
      return BootstrapPhase.databaseError;
    }
    if (!dbHasValue || !marketingBeatComplete) {
      return BootstrapPhase.splash;
    }
    return BootstrapPhase.ready;
  }
}