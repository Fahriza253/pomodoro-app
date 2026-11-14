import 'package:flutter_test/flutter_test.dart';
import 'package:pomodoro_app/app/theme/app_theme.dart';
import 'package:pomodoro_app/app/theme/chart_series_colors.dart';

void main() {
  group('chartSeriesColors', () {
    test('light theme exposes six MASTER series tokens', () {
      final scheme = AppThemeData.light().colorScheme;
      final colors = chartSeriesColors(scheme);
      expect(colors, hasLength(6));
      expect(colors[0], scheme.primary);
      expect(colors[1], scheme.tertiary);
      expect(colors[2], scheme.secondary);
      expect(colors[3], scheme.primaryContainer);
      expect(colors[4], scheme.outline);
    });

    test('index wraps after six series', () {
      final scheme = AppThemeData.dark().colorScheme;
      expect(chartSeriesColorForIndex(scheme, 0), scheme.primary);
      expect(chartSeriesColorForIndex(scheme, 6), scheme.primary);
    });
  });
}
