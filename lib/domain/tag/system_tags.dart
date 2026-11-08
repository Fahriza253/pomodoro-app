/// Built-in / reserved tag identities (BR-TAG-001).
abstract final class SystemTags {
  /// Seeded default tag; must not be deletable.
  static const generalName = 'General';

  /// QA-only Tag (5s durations) when `--dart-define=DEBUG_SHORT_TAG=true`.
  static const debugName = 'Debug 5s';
}
