/// Pure plan for now-firing Alert / Reminder delivery (BR-SETTINGS-010).
///
/// Focus failure and Flexible Reminder fire immediately — they are not
/// pre-scheduled. OS schedule (AlarmManager / equivalent) is out of scope.
enum ImmediateEventDelivery {
  /// Alert Controls in-app (tone / haptic / flash).
  inApp,

  /// Post one OS notification now.
  osImmediate,

  /// Already delivered, or wait for visible catch-up after a failed OS post.
  silent,
}

/// Chooses in-app vs one-shot OS vs silent for a now-firing event.
///
/// [osPosted] is true only if the adapter accepted the immediate OS post.
/// [osPostAttempted] is true if we tried — a failed post must not be treated
/// as OS-owned (in-app fallback when visible). [inAppPlayed] is true after a
/// successful foreground delivery of this same event.
ImmediateEventDelivery planImmediateEventFire({
  required bool foreground,
  required bool osPosted,
  required bool osPostAttempted,
  required bool inAppPlayed,
}) {
  if (osPosted || inAppPlayed) {
    return ImmediateEventDelivery.silent;
  }
  if (foreground) {
    return ImmediateEventDelivery.inApp;
  }
  if (osPostAttempted) {
    return ImmediateEventDelivery.silent;
  }
  return ImmediateEventDelivery.osImmediate;
}
