import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pomodoro_app/app/timer_providers.dart';
import 'package:pomodoro_app/domain/common/app_error.dart';
import 'package:pomodoro_app/domain/common/result.dart';
import 'package:pomodoro_app/presentation/l10n/l10n_extensions.dart';
import 'package:pomodoro_app/presentation/timer/timer_error_messages.dart';

Future<bool> runTimerAction(
  BuildContext context,
  WidgetRef ref,
  Future<AppResult<void>> Function() action,
) async {
  final result = await action();
  if (!context.mounted) {
    return result.isOk;
  }
  if (result.isErr) {
    _showTimerError(context, result.error!);
  }
  return result.isOk;
}

void _showTimerError(BuildContext context, AppError error) {
  ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text(timerErrorMessage(error, context.l10n))));
}

void showTimerMessage(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}

/// Stops the active session immediately (slide-to-stop; no confirm dialog).
Future<void> stopSession(BuildContext context, WidgetRef ref) async {
  await runTimerAction(
    context,
    ref,
    () => ref.read(timerCoordinatorProvider).stop(confirmed: true),
  );
}
