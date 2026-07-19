import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Android status icons must be white+alpha drawables, not full-color mipmaps.
void main() {
  test('ic_stat_pomodoro drawable exists for notification small icon', () {
    final file = File('android/app/src/main/res/drawable/ic_stat_pomodoro.xml');
    expect(file.existsSync(), isTrue);
    final xml = file.readAsStringSync();
    expect(xml, contains('#FFFFFFFF'));
    expect(xml, isNot(contains('launcher_icon')));
  });
}
