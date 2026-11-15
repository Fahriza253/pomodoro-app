/// Post-session-complete action for the facade after segment-end Alerts.
enum SessionTerminalFollowUp {
  /// Pomodoro soft-complete: Session stays active until Done or restart.
  none,

  /// Flexible: persist completed Session, keep tag context for summary UI.
  persistCompletedKeepUi,
}