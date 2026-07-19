import 'package:flutter_test/flutter_test.dart';
import 'package:pomodoro_app/l10n/app_localizations.dart';
import 'package:pomodoro_app/l10n/l10n_lookup.dart';

void main() {
  group('l10nFor', () {
    test('returns English for en', () {
      final l10n = l10nFor('en');
      expect(l10n.navTimer, 'Timer');
      expect(l10n.tryAgain, 'Try again');
      expect(l10n.deletedTag, 'Deleted tag');
    });

    test('returns Indonesian for id', () {
      final l10n = l10nFor('id');
      expect(l10n.tryAgain, 'Coba lagi');
      expect(l10n.deletedTag, 'Tag terhapus');
      expect(l10n.databaseNotReadyTitle, isNotEmpty);
    });

    test('falls back to English for unknown codes', () {
      final l10n = l10nFor('fr');
      expect(l10n.navSettings, l10nFor('en').navSettings);
    });

    test('lookupAppLocalizations covers supported locales', () {
      for (final locale in AppLocalizations.supportedLocales) {
        expect(lookupAppLocalizations(locale), isA<AppLocalizations>());
      }
    });
  });
}
