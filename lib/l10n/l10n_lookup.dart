import 'package:flutter/widgets.dart';
import 'package:pomodoro_app/l10n/app_localizations.dart';

/// Lookup localizations without a [BuildContext] (notifications, coordinators).
AppLocalizations l10nFor(String languageCode) {
  final code = switch (languageCode) {
    'id' => 'id',
    _ => 'en',
  };
  return lookupAppLocalizations(Locale(code));
}
