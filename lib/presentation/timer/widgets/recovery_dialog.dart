import 'package:flutter/material.dart';
import 'package:pomodoro_app/presentation/l10n/l10n_extensions.dart';

class RecoveryDialog extends StatelessWidget {
  const RecoveryDialog({
    required this.onResume,
    required this.onDecline,
    super.key,
  });

  final VoidCallback onResume;
  final VoidCallback onDecline;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AlertDialog(
      title: Text(l10n.recoveryDialogTitle),
      content: Text(l10n.recoveryDialogBody),
      actions: [
        TextButton(onPressed: onDecline, child: Text(l10n.discard)),
        FilledButton(onPressed: onResume, child: Text(l10n.resumeSession)),
      ],
    );
  }

  static Future<void> showIfNeeded(
    BuildContext context, {
    required bool show,
    required VoidCallback onResume,
    required VoidCallback onDecline,
  }) async {
    if (!show) {
      return;
    }
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => RecoveryDialog(
        onResume: () {
          Navigator.of(context).pop();
          onResume();
        },
        onDecline: () {
          Navigator.of(context).pop();
          onDecline();
        },
      ),
    );
  }
}
