import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pomodoro_app/l10n/app_localizations.dart';
import 'package:pomodoro_app/presentation/l10n/l10n_lookup.dart';
import 'package:pomodoro_app/presentation/settings/settings_providers.dart';

/// Current UI language code from settings — defaults to English.
final localeCodeProvider = Provider<String>((ref) {
  return ref
      .watch(appSettingsStreamProvider)
      .maybeWhen(data: (s) => s.language, orElse: () => 'en');
});

final appLocalizationsProvider = Provider<AppLocalizations>((ref) {
  return l10nFor(ref.watch(localeCodeProvider));
});
