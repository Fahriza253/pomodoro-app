import 'package:pomodoro_app/application/timer/recovery_check_result.dart';
import 'package:pomodoro_app/data/repositories/active_timer_state_repository.dart';
import 'package:pomodoro_app/data/repositories/session_repository.dart';
import 'package:pomodoro_app/domain/common/enums.dart';

/// Bootstrap recovery cross-check (BR-TIMER-021–024).
class SessionRecoveryService {
  SessionRecoveryService({
    required this._sessionRepository,
    required this._activeTimerStateRepository,
  });

  final SessionRepository _sessionRepository;
  final ActiveTimerStateRepository _activeTimerStateRepository;

  static const recoveryWindow = Duration(hours: 24);

  Future<RecoveryCheckResult> check(DateTime nowUtc) async {
    final state = await _activeTimerStateRepository.get();
    final session = state != null
        ? await _sessionRepository.getById(state.sessionId)
        : null;
    final orphanActive = await _sessionRepository.getActiveSession();

    // Case 1: ActiveTimerState without valid active Session.
    if (state != null &&
        (session == null || session.status != SessionStatus.active)) {
      await _activeTimerStateRepository.delete();
      if (orphanActive != null && orphanActive.id != state.sessionId) {
        await _sessionRepository.markAbandoned(orphanActive.id, nowUtc);
      }
      return const RecoveryCheckNone();
    }

    // Case 2: Active Session without ActiveTimerState.
    if (state == null && orphanActive != null) {
      await _sessionRepository.markAbandoned(orphanActive.id, nowUtc);
      return RecoveryCheckAutoAbandoned(orphanActive.id);
    }

    // Case 3: Both exist — normal recovery path.
    if (state != null &&
        session != null &&
        session.status == SessionStatus.active) {
      // Session-complete UI already means work is done — persist completed,
      // never offer "continue session" (user already finished the run).
      if (state.enginePhase == EnginePhase.sessionComplete) {
        await _sessionRepository.markCompleted(session.id, nowUtc);
        await _activeTimerStateRepository.delete();
        return RecoveryCheckAutoCompleted(session.id);
      }

      final elapsed = nowUtc.difference(
        DateTime.fromMillisecondsSinceEpoch(
          state.lastPersistedAtUtcMs,
          isUtc: true,
        ),
      );
      if (elapsed >= recoveryWindow) {
        await _sessionRepository.markAbandoned(session.id, nowUtc);
        await _activeTimerStateRepository.delete();
        return RecoveryCheckAutoAbandoned(session.id);
      }
      return RecoveryCheckOfferResume(state);
    }

    return const RecoveryCheckNone();
  }
}
