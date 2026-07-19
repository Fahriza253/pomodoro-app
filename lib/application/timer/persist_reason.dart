/// Allowed persist triggers (BR-TIMER-025).
enum PersistReason {
  sessionStart,
  pause,
  resume,
  segmentTransition,
  lifecycleFlush,
}
