import 'package:pomodoro_app/domain/common/enums.dart';

/// Pure-Dart notification copy for timer Alerts and OS surfaces.
///
/// Keep segment-end templates in sync with UX copy used on the timer screen.
class NotificationStrings {
  const NotificationStrings({
    required this.focusing,
    required this.resting,
    required this.sessionStoppedTitle,
    required this.sessionStoppedBody,
    required this.focusCompleteTitle,
    required this.breakCompleteTitle,
    required this.timeForBreak,
    required this.timeForFocus,
    required this.focusFailedTitle,
    required this.focusViolationBody,
    required this.focusReminderTitle,
    required this.focusReminderBody,
    required this.sessionCompleteTitle,
    required this.segmentFocus,
    required this.segmentShortRest,
    required this.segmentLongRest,
    required this.segmentFlexible,
    required this.segmentCompleteTitleTemplate,
    required this.segmentEndBodyWithNextTemplate,
    required this.segmentEndBodySessionCompleteTemplate,
  });

  factory NotificationStrings.forLanguage(String languageCode) =>
      languageCode == 'id' ? id : en;

  final String focusing;
  final String resting;
  final String sessionStoppedTitle;
  final String sessionStoppedBody;
  final String focusCompleteTitle;
  final String breakCompleteTitle;
  final String timeForBreak;
  final String timeForFocus;
  final String focusFailedTitle;
  final String focusViolationBody;
  final String focusReminderTitle;
  final String focusReminderBody;
  final String sessionCompleteTitle;
  final String segmentFocus;
  final String segmentShortRest;
  final String segmentLongRest;
  final String segmentFlexible;
  final String segmentCompleteTitleTemplate;
  final String segmentEndBodyWithNextTemplate;
  final String segmentEndBodySessionCompleteTemplate;

  String segmentLabel(SegmentType type) => switch (type) {
    SegmentType.focus => segmentFocus,
    SegmentType.shortRest => segmentShortRest,
    SegmentType.longRest => segmentLongRest,
    SegmentType.flexible => segmentFlexible,
  };

  String segmentCompleteTitle(String finishedLabel) =>
      segmentCompleteTitleTemplate.replaceAll('{label}', finishedLabel);

  String segmentEndBodyWithNext(
    String finishedLabel,
    String nextLabel,
    int completedCount,
    int totalCount,
  ) => segmentEndBodyWithNextTemplate
      .replaceAll('{finished}', finishedLabel)
      .replaceAll('{next}', nextLabel)
      .replaceAll('{n}', '$completedCount')
      .replaceAll('{total}', '$totalCount');

  String segmentEndBodySessionComplete(
    String finishedLabel,
    int completedCount,
    int totalCount,
  ) => segmentEndBodySessionCompleteTemplate
      .replaceAll('{finished}', finishedLabel)
      .replaceAll('{n}', '$completedCount')
      .replaceAll('{total}', '$totalCount');

  static const en = NotificationStrings(
    focusing: 'Focusing',
    resting: 'Resting',
    sessionStoppedTitle: 'Session stopped',
    sessionStoppedBody: 'Your session has been stopped',
    focusCompleteTitle: 'Focus complete',
    breakCompleteTitle: 'Break complete',
    timeForBreak: 'Time for a break',
    timeForFocus: 'Time to focus',
    focusFailedTitle: 'Focus session failed',
    focusViolationBody: 'You left the app during focus mode',
    focusReminderTitle: 'Focus reminder',
    focusReminderBody: 'Stay focused, your session is still running',
    sessionCompleteTitle: 'Session complete',
    segmentFocus: 'Focus',
    segmentShortRest: 'Short break',
    segmentLongRest: 'Long break',
    segmentFlexible: 'Flexible',
    segmentCompleteTitleTemplate: '{label} complete',
    segmentEndBodyWithNextTemplate:
        '{finished} finished. Next: {next}. Cycle {n} of {total}.',
    segmentEndBodySessionCompleteTemplate:
        '{finished} finished. Session complete. Cycle {n} of {total}.',
  );

  static const id = NotificationStrings(
    focusing: 'Sedang focus',
    resting: 'Sedang istirahat',
    sessionStoppedTitle: 'Session dihentikan',
    sessionStoppedBody: 'Session Anda telah dihentikan',
    focusCompleteTitle: 'Focus selesai',
    breakCompleteTitle: 'Istirahat selesai',
    timeForBreak: 'Waktunya istirahat',
    timeForFocus: 'Waktunya focus',
    focusFailedTitle: 'Session focus gagal',
    focusViolationBody: 'Anda meninggalkan aplikasi selama mode focus',
    focusReminderTitle: 'Pengingat focus',
    focusReminderBody: 'Tetap fokus, session Anda masih berjalan',
    sessionCompleteTitle: 'Session selesai',
    segmentFocus: 'Focus',
    segmentShortRest: 'Istirahat pendek',
    segmentLongRest: 'Istirahat panjang',
    segmentFlexible: 'Flexible',
    segmentCompleteTitleTemplate: '{label} selesai',
    segmentEndBodyWithNextTemplate:
        '{finished} selesai. Berikutnya: {next}. Siklus {n} dari {total}.',
    segmentEndBodySessionCompleteTemplate:
        '{finished} selesai. Session selesai. Siklus {n} dari {total}.',
  );
}
