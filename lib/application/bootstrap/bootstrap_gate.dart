/// Cold-start phase before the main shell (see `docs/design/pages/splash.md`).
enum BootstrapPhase {
  /// Local database open or seed failed; marketing beat skipped.
  databaseError,

  /// Waiting on the local database. Marketing beat runs as an overlay.
  splash,

  /// Main navigation may mount under the splash overlay.
  ready,
}

/// Chooses the bootstrap phase from DB readiness.
abstract final class BootstrapGate {
  static BootstrapPhase phase({
    required bool dbHasError,
    required bool dbHasValue,
  }) {
    if (dbHasError) {
      return BootstrapPhase.databaseError;
    }
    if (!dbHasValue) {
      return BootstrapPhase.splash;
    }
    return BootstrapPhase.ready;
  }
}
