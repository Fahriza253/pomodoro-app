import 'package:pomodoro_app/domain/common/enums.dart';
import 'package:pomodoro_app/domain/settings/focus_mode_capabilities.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('coerces unavailable modes to loose', () {
    expect(
      effectiveFocusMode(
        FocusMode.strict,
        strictAvailable: false,
        whitelistAvailable: true,
      ),
      FocusMode.loose,
    );
    expect(
      effectiveFocusMode(
        FocusMode.whitelist,
        strictAvailable: true,
        whitelistAvailable: false,
      ),
      FocusMode.loose,
    );
    expect(
      effectiveFocusMode(
        FocusMode.loose,
        strictAvailable: false,
        whitelistAvailable: false,
      ),
      FocusMode.loose,
    );
  });
}
