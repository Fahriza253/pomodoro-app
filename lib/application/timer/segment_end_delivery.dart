/// Pure plan for segment-end Alert delivery (BR-SETTINGS-010).
///
/// OS schedule owns background segment-end; in-app owns a live foreground
/// complete. Catch-up after a successful enqueue is silent.
enum SegmentEndFireDelivery {
  /// Alert Controls in-app (tone / haptic / flash).
  inApp,

  /// Post an OS notification now (nothing scheduled, or cannot schedule past).
  osImmediate,

  /// Do not deliver — suppress, OS schedule owns, or catch-up after enqueue.
  silent,
}

enum SegmentEndScheduleDecision {
  /// Do not schedule (UI visible, or remaining ≤ 0).
  skip,

  /// Enqueue this segment's fire time. Use a per-segment notification id so a
  /// due/past post is not replaced.
  replace,

  /// Pending fire time is due or past — leave it for the OS.
  leaveDue,
}

/// Chooses in-app vs OS-immediate vs silent at segment-end fire time.
///
/// [scheduleEnqueued] is true only if the adapter accepted the OS schedule.
/// [enqueueAttempted] is true if we tried and may have failed — failed enqueue
/// must not be treated as OS-owned (in-app fallback when visible).
/// [osOwnedCatchUp] is armed on resume when wall-clock says the scheduled fire
/// already passed (or cold start remaining ≤ 0); it is ignored when enqueue
/// failed.
SegmentEndFireDelivery planSegmentEndFire({
  required bool foreground,
  required bool suppress,
  required bool scheduleEnqueued,
  required DateTime? scheduledFireAtUtc,
  required DateTime nowUtc,
  bool enqueueAttempted = false,
  bool osOwnedCatchUp = false,
}) {
  if (suppress) {
    return SegmentEndFireDelivery.silent;
  }
  final dueOrPast =
      scheduledFireAtUtc != null && !nowUtc.isBefore(scheduledFireAtUtc);
  final enqueueFailed = enqueueAttempted && !scheduleEnqueued;
  if (osOwnedCatchUp && !enqueueFailed) {
    return SegmentEndFireDelivery.silent;
  }
  if (foreground) {
    if (dueOrPast && scheduleEnqueued) {
      return SegmentEndFireDelivery.silent;
    }
    return SegmentEndFireDelivery.inApp;
  }
  if (scheduleEnqueued) {
    return SegmentEndFireDelivery.silent;
  }
  return SegmentEndFireDelivery.osImmediate;
}

SegmentEndScheduleDecision planSegmentEndSchedule({
  required bool foreground,
  required int remainingSec,
  required DateTime? existingFireAtUtc,
  required DateTime nowUtc,
}) {
  if (foreground || remainingSec <= 0) {
    return SegmentEndScheduleDecision.skip;
  }
  if (existingFireAtUtc != null && !nowUtc.isAfter(existingFireAtUtc)) {
    return SegmentEndScheduleDecision.leaveDue;
  }
  return SegmentEndScheduleDecision.replace;
}
