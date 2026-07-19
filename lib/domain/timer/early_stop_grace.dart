/// Early-stop grace window (BR-TIMER-026).
///
/// If the user stops while active elapsed time is still below this threshold,
/// the session is discarded (not persisted as abandoned) and excluded from
/// Statistic.
const int kEarlyStopGraceSec = 10;

/// Remaining grace seconds given [activeElapsedSec], clamped to `0..grace`.
int earlyStopGraceRemainingSec(int activeElapsedSec) {
  if (activeElapsedSec >= kEarlyStopGraceSec) {
    return 0;
  }
  if (activeElapsedSec <= 0) {
    return kEarlyStopGraceSec;
  }
  return kEarlyStopGraceSec - activeElapsedSec;
}

/// Whether stop should discard the session instead of abandoning it.
bool isWithinEarlyStopGrace(int activeElapsedSec) =>
    activeElapsedSec < kEarlyStopGraceSec;
