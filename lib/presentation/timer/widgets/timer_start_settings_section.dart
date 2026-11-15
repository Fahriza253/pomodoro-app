import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pomodoro_app/domain/common/result.dart';
import 'package:pomodoro_app/domain/settings/app_settings.dart';
import 'package:pomodoro_app/presentation/l10n/l10n_extensions.dart';
import 'package:pomodoro_app/presentation/settings/settings_error_messages.dart';
import 'package:pomodoro_app/presentation/settings/settings_providers.dart';

/// Pomodoro start options (timer screen sheet).
class TimerStartSettingsSection extends ConsumerStatefulWidget {
  const TimerStartSettingsSection({super.key});

  @override
  ConsumerState<TimerStartSettingsSection> createState() =>
      _TimerStartSettingsSectionState();
}

class _TimerStartSettingsSectionState
    extends ConsumerState<TimerStartSettingsSection> {
  bool _saving = false;

  Future<void> _save(AppSettingsPatch patch) async {
    if (_saving) return;
    setState(() => _saving = true);
    final result = await ref
        .read(settingsUseCasesProvider)
        .updateSettings(patch);
    if (!mounted) return;
    setState(() => _saving = false);
    if (result.isErr) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(settingsErrorMessage(result.error!, context.l10n)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(appSettingsStreamProvider);
    final l10n = context.l10n;

    return settingsAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.all(24),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (_, _) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.loadSettingsFailed),
            const SizedBox(height: 8),
            FilledButton(
              onPressed: () => ref.invalidate(appSettingsStreamProvider),
              child: Text(l10n.tryAgain),
            ),
          ],
        ),
      ),
      data: (settings) {
        return CheckboxListTile(
          value: settings.pomodoroPreStartCountdown,
          onChanged: _saving
              ? null
              : (checked) => _save(
                    AppSettingsPatch(
                      pomodoroPreStartCountdown: checked ?? false,
                    ),
                  ),
          title: Text(l10n.timerPreStartCountdownTitle),
          subtitle: Text(
            l10n.timerPreStartCountdownSubtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          controlAffinity: ListTileControlAffinity.leading,
        );
      },
    );
  }
}

Future<void> showTimerStartSettingsSheet(BuildContext context) {
  final l10n = context.l10n;
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (sheetContext) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Text(
                  l10n.timerStartSettingsSheetTitle,
                  style: Theme.of(sheetContext).textTheme.titleMedium,
                ),
              ),
              const TimerStartSettingsSection(),
            ],
          ),
        ),
      );
    },
  );
}