import 'package:pomodoro_app/domain/common/enums.dart';
import 'package:pomodoro_app/l10n/app_localizations.dart';

String segmentTypeLabel(AppLocalizations l10n, SegmentType? type) =>
    switch (type) {
      SegmentType.focus => l10n.segmentFocus,
      SegmentType.shortRest => l10n.segmentShortRest,
      SegmentType.longRest => l10n.segmentLongRest,
      SegmentType.flexible => l10n.segmentFlexible,
      null => '',
    };

bool isRestSegment(SegmentType? type) =>
    type == SegmentType.shortRest || type == SegmentType.longRest;
