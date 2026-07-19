import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pomodoro_app/domain/common/result.dart';
import 'package:pomodoro_app/domain/settings/app_settings.dart';
import 'package:pomodoro_app/presentation/l10n/l10n_extensions.dart';
import 'package:pomodoro_app/presentation/settings/settings_error_messages.dart';
import 'package:pomodoro_app/presentation/settings/settings_providers.dart';

class StatisticsSettingsScreen extends ConsumerStatefulWidget {
  const StatisticsSettingsScreen({super.key});

  @override
  ConsumerState<StatisticsSettingsScreen> createState() =>
      _StatisticsSettingsScreenState();
}

class _StatisticsSettingsScreenState
    extends ConsumerState<StatisticsSettingsScreen> {
  bool _saving = false;

  Future<void> _save(AppSettingsPatch patch) async {
    setState(() => _saving = true);
    final result = await ref
        .read(settingsUseCasesProvider)
        .updateSettings(patch);
    if (!mounted) return;
    setState(() => _saving = false);
    if (result.isErr) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(settingsErrorMessage(result.error!, context.l10n))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(appSettingsStreamProvider);
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.statisticInclusionTitle)),
      body: settingsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => Center(child: Text(l10n.loadSettingsFailed)),
        data: (settings) => AbsorbPointer(
          absorbing: _saving,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              SwitchListTile(
                title: Text(l10n.trackFailedSessions),
                subtitle: Text(l10n.trackFailedSessionsSubtitle),
                value: settings.trackFailedSessions,
                onChanged: (value) =>
                    _save(AppSettingsPatch(trackFailedSessions: value)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
