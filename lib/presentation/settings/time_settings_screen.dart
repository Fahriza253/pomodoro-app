import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pomodoro_app/domain/common/enums.dart';
import 'package:pomodoro_app/domain/common/result.dart';
import 'package:pomodoro_app/domain/settings/app_settings.dart';
import 'package:pomodoro_app/presentation/l10n/l10n_extensions.dart';
import 'package:pomodoro_app/presentation/settings/settings_error_messages.dart';
import 'package:pomodoro_app/presentation/settings/settings_providers.dart';

class TimeSettingsScreen extends ConsumerStatefulWidget {
  const TimeSettingsScreen({super.key});

  @override
  ConsumerState<TimeSettingsScreen> createState() => _TimeSettingsScreenState();
}

class _TimeSettingsScreenState extends ConsumerState<TimeSettingsScreen> {
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
      appBar: AppBar(title: Text(l10n.timeLanguageTitle)),
      body: settingsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => Center(child: Text(l10n.loadSettingsFailed)),
        data: (settings) => AbsorbPointer(
          absorbing: _saving,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              DropdownButtonFormField<String>(
                initialValue: settings.language,
                decoration: InputDecoration(
                  labelText: l10n.language,
                  border: const OutlineInputBorder(),
                ),
                items: [
                  DropdownMenuItem(
                    value: 'id',
                    child: Text(l10n.languageIndonesian),
                  ),
                  DropdownMenuItem(
                    value: 'en',
                    child: Text(l10n.languageEnglish),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    _save(AppSettingsPatch(language: value));
                  }
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<TimeFormat>(
                initialValue: settings.timeFormat,
                decoration: InputDecoration(
                  labelText: l10n.timeFormat,
                  border: const OutlineInputBorder(),
                ),
                items: [
                  DropdownMenuItem(
                    value: TimeFormat.h24,
                    child: Text(l10n.timeFormat24h),
                  ),
                  DropdownMenuItem(
                    value: TimeFormat.h12,
                    child: Text(l10n.timeFormat12h),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    _save(AppSettingsPatch(timeFormat: value));
                  }
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                initialValue: settings.weekStartDay,
                decoration: InputDecoration(
                  labelText: l10n.weekStart,
                  border: const OutlineInputBorder(),
                ),
                items: [
                  DropdownMenuItem(
                    value: 1,
                    child: Text(l10n.weekStartMonday),
                  ),
                  DropdownMenuItem(
                    value: 0,
                    child: Text(l10n.weekStartSunday),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    _save(AppSettingsPatch(weekStartDay: value));
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
