import 'dart:math';

import 'package:pomodoro_app/application/timer/notification_strings.dart';
import 'package:pomodoro_app/application/timer/segment_end_copy.dart';
import 'package:pomodoro_app/application/timer/timer_view_state.dart';
import 'package:pomodoro_app/domain/common/enums.dart';
import 'package:pomodoro_app/l10n/app_localizations.dart';
import 'package:pomodoro_app/presentation/timer/timer_format.dart';

/// Visit-scoped soft-complete presentation for [EnginePhase.sessionComplete].
///
/// Create once when soft-complete UI mounts; discard when leaving the phase.
/// Holds the Pomodoro celebration body index for the visit.
final class SoftCompletePresentationIntent {
  SoftCompletePresentationIntent({Random? random})
    : _bodyIndex = (random ?? Random()).nextInt(_bodyVariantCount);

  static const _bodyVariantCount = 3;
  static const lottieAsset = 'assets/lottie/winner.json';

  final int _bodyIndex;

  /// Resolve paint model + coordinator wire targets.
  SoftCompleteScreen present({
    required TimerViewState view,
    required AppLocalizations l10n,
    required String languageCode,
  }) {
    if (view.mode == TimerMode.pomodoro) {
      return SoftCompleteCelebration(
        lottieAsset: lottieAsset,
        headline: l10n.sessionCompleteYouDidIt,
        body: _celebrationBody(l10n),
        primary: SoftCompleteAction(
          label: l10n.startNewSession,
          wire: SoftCompleteWireTarget.restartSameTag,
        ),
        secondary: SoftCompleteAction(
          label: l10n.backToHome,
          wire: SoftCompleteWireTarget.dismissSessionComplete,
        ),
      );
    }

    final endCopy = view.hasSegmentEndSummary
        ? SegmentEndCopy.build(
            strings: NotificationStrings.forLanguage(languageCode),
            finished: view.segmentEndFinishedType!,
            next: view.segmentEndNextType,
            completedCount: view.segmentEndCompletedCount!,
            totalCount: view.segmentEndTotalCount!,
            sessionComplete: true,
          )
        : null;
    final duration = formatTimerSeconds(view.displaySec, forceHours: true);

    return SoftCompleteSimple(
      headline: endCopy?.title ?? l10n.sessionCompleteTitle,
      segmentEndBody: endCopy?.body,
      savedLine: l10n.sessionSavedBody,
      durationLine: l10n.activeDuration(duration),
      primary: SoftCompleteAction(
        label: l10n.startAgainUpper,
        wire: SoftCompleteWireTarget.restartSameTag,
      ),
      secondary: SoftCompleteAction(
        label: l10n.doneUpper,
        wire: SoftCompleteWireTarget.dismissSessionComplete,
      ),
    );
  }

  String _celebrationBody(AppLocalizations l10n) {
    return switch (_bodyIndex % _bodyVariantCount) {
      0 => l10n.sessionCompleteBodyCasual,
      1 => l10n.sessionCompleteBodyBrief,
      _ => l10n.sessionCompleteBodyMotivational,
    };
  }
}

/// Discriminated paint model for soft-complete UI.
sealed class SoftCompleteScreen {
  SoftCompleteAction get primary;
  SoftCompleteAction get secondary;
}

/// Pomodoro celebration chrome (Lottie + headline + body).
final class SoftCompleteCelebration extends SoftCompleteScreen {
  SoftCompleteCelebration({
    required this.lottieAsset,
    required this.headline,
    required this.body,
    required this.primary,
    required this.secondary,
  });

  final String lottieAsset;
  final String headline;
  final String body;

  @override
  final SoftCompleteAction primary;
  @override
  final SoftCompleteAction secondary;
}

/// Flexible simple chrome.
final class SoftCompleteSimple extends SoftCompleteScreen {
  SoftCompleteSimple({
    required this.headline,
    this.segmentEndBody,
    required this.savedLine,
    required this.durationLine,
    required this.primary,
    required this.secondary,
  });

  final String headline;
  final String? segmentEndBody;
  final String savedLine;
  final String durationLine;

  @override
  final SoftCompleteAction primary;
  @override
  final SoftCompleteAction secondary;
}

final class SoftCompleteAction {
  const SoftCompleteAction({required this.label, required this.wire});

  final String label;
  final SoftCompleteWireTarget wire;
}

/// Maps 1:1 to [TimerCoordinator] methods. UI owns the call.
enum SoftCompleteWireTarget { restartSameTag, dismissSessionComplete }
