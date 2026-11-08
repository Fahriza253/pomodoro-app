import 'package:pomodoro_app/domain/common/enums.dart';

/// Effective focus mode when platform caps disallow persisted Strict/Whitelist.
FocusMode effectiveFocusMode(
  FocusMode persisted, {
  required bool strictAvailable,
  required bool whitelistAvailable,
}) {
  return switch (persisted) {
    FocusMode.strict when !strictAvailable => FocusMode.loose,
    FocusMode.whitelist when !whitelistAvailable => FocusMode.loose,
    _ => persisted,
  };
}
