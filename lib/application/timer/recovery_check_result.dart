import 'package:pomodoro_app/domain/timer/active_timer_state.dart';

/// Bootstrap recovery outcome ([API_CONTRACT](docs/internal/system/implementation/API_CONTRACT.md)).
sealed class RecoveryCheckResult {
  const RecoveryCheckResult();
}

final class RecoveryCheckNone extends RecoveryCheckResult {
  const RecoveryCheckNone();
}

final class RecoveryCheckOfferResume extends RecoveryCheckResult {
  const RecoveryCheckOfferResume(this.state);

  final ActiveTimerState state;
}

final class RecoveryCheckAutoAbandoned extends RecoveryCheckResult {
  const RecoveryCheckAutoAbandoned(this.sessionId);

  final String sessionId;
}

/// Session was at [EnginePhase.sessionComplete]; finalized as completed.
final class RecoveryCheckAutoCompleted extends RecoveryCheckResult {
  const RecoveryCheckAutoCompleted(this.sessionId);

  final String sessionId;
}
