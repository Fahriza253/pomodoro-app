import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pomodoro_app/app/theme/app_theme.dart';
import 'package:pomodoro_app/app/theme/segment_semantic_color.dart';
import 'package:pomodoro_app/domain/common/enums.dart';

void main() {
  group('segmentSemanticColor', () {
    for (final entry in <(SegmentType, Color Function(ColorScheme) token)>[
      (SegmentType.focus, (s) => s.primary),
      (SegmentType.shortRest, (s) => s.tertiary),
      (SegmentType.longRest, (s) => s.secondary),
      (SegmentType.flexible, (s) => s.primary),
    ]) {
      final (type, token) = entry;

      test('light theme ${type.name}', () {
        final scheme = AppThemeData.light().colorScheme;
        expect(segmentSemanticColor(scheme, type), token(scheme));
      });

      test('dark theme ${type.name}', () {
        final scheme = AppThemeData.dark().colorScheme;
        expect(segmentSemanticColor(scheme, type), token(scheme));
      });
    }
  });

  group('segmentSemanticColor widget', () {
    Future<void> expectProbeColor(
      WidgetTester tester, {
      required ThemeData theme,
      required SegmentType type,
      required Color expected,
    }) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Builder(
            builder: (context) {
              final color = segmentSemanticColor(
                Theme.of(context).colorScheme,
                type,
              );
              return ColoredBox(
                key: const Key('segment_color_probe'),
                color: color,
                child: const SizedBox(width: 1, height: 1),
              );
            },
          ),
        ),
      );
      final box = tester.widget<ColoredBox>(
        find.byKey(const Key('segment_color_probe')),
      );
      expect(box.color, expected);
    }

    testWidgets('reads ColorScheme from Theme in light mode', (tester) async {
      final theme = AppThemeData.light();
      final scheme = theme.colorScheme;
      await expectProbeColor(
        tester,
        theme: theme,
        type: SegmentType.longRest,
        expected: scheme.secondary,
      );
    });

    testWidgets('reads ColorScheme from Theme in dark mode', (tester) async {
      final theme = AppThemeData.dark();
      final scheme = theme.colorScheme;
      await expectProbeColor(
        tester,
        theme: theme,
        type: SegmentType.shortRest,
        expected: scheme.tertiary,
      );
    });
  });
}
