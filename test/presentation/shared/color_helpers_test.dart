import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pomodoro_app/presentation/shared/color_helpers.dart';

void main() {
  group('parseHexColor', () {
    test('parses #RRGGBB', () {
      expect(parseHexColor('#EF4444'), const Color(0xFFEF4444));
    });

    test('parses RRGGBB without hash', () {
      expect(parseHexColor('9CA3AF'), const Color(0xFF9CA3AF));
    });

    test('returns null for invalid length', () {
      expect(parseHexColor('#FFF'), isNull);
      expect(parseHexColor(''), isNull);
    });

    test('returns null for non-hex characters', () {
      expect(parseHexColor('#GGGGGG'), isNull);
    });
  });

  group('parseHexColorOr', () {
    test('returns parsed color when valid', () {
      expect(parseHexColorOr('#000000', Colors.red), const Color(0xFF000000));
    });

    test('returns fallback when invalid', () {
      expect(parseHexColorOr('bad', Colors.indigo), Colors.indigo);
    });
  });
}
