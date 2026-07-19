class StatisticSummary {
  const StatisticSummary({
    required this.sessionCount,
    required this.focusDurationSec,
    required this.breakDurationSec,
    required this.totalDurationSec,
    required this.byTag,
  });

  final int sessionCount;
  final int focusDurationSec;
  final int breakDurationSec;
  final int totalDurationSec;
  final List<TagBreakdown> byTag;
}

class TagBreakdown {
  const TagBreakdown({
    required this.tagId,
    required this.tagName,
    required this.tagColor,
    required this.sessionCount,
    required this.focusDurationSec,
    required this.breakDurationSec,
  });

  final String tagId;
  final String tagName;
  final String tagColor;
  final int sessionCount;
  final int focusDurationSec;
  final int breakDurationSec;
}
