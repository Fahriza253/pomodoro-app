import 'package:pomodoro_app/domain/common/app_error.dart';
import 'package:pomodoro_app/l10n/app_localizations.dart';

String tagErrorMessage(AppError error, AppLocalizations l10n) {
  return switch (error.code) {
    'TAG_NAME_DUPLICATE' => l10n.errorTagNameDuplicate,
    'TAG_CONFIG_INVALID' => error.message,
    'TAG_EDIT_BLOCKED_ACTIVE' => l10n.errorTagEditBlockedActive,
    'TAG_DELETE_LAST' => l10n.errorTagDeleteLast,
    'TAG_NOT_FOUND' => l10n.errorTagNotFound,
    _ => error.message,
  };
}
