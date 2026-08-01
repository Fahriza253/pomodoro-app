/// Pure plan for Alert / Reminder modality at fire time (BR-SETTINGS-007–010).
class AlertModalityPlan {
  const AlertModalityPlan({
    required this.playInAppSound,
    required this.triggerHaptic,
    required this.triggerFlash,
    required this.osNotificationPlaySound,
  });

  /// Foreground in-app tone (false when muted or not foreground).
  final bool playInAppSound;

  final bool triggerHaptic;

  /// Camera/torch flash — foreground + capable only (BR-SETTINGS-009).
  final bool triggerFlash;

  /// When showing an OS local notification, whether it should play sound.
  final bool osNotificationPlaySound;
}

AlertModalityPlan planAlertModalities({
  required bool foreground,
  required bool soundMuted,
  required bool hapticEnabled,
  required bool flashEnabled,
  required bool flashCapable,
}) {
  return AlertModalityPlan(
    playInAppSound: foreground && !soundMuted,
    triggerHaptic: foreground && hapticEnabled,
    triggerFlash: foreground && flashEnabled && flashCapable,
    osNotificationPlaySound: !soundMuted,
  );
}
