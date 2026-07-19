import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pomodoro_app/domain/common/enums.dart';
import 'package:pomodoro_app/domain/common/result.dart';
import 'package:pomodoro_app/domain/settings/app_settings.dart';
import 'package:pomodoro_app/l10n/app_localizations.dart';
import 'package:pomodoro_app/presentation/l10n/l10n_extensions.dart';
import 'package:pomodoro_app/presentation/settings/settings_error_messages.dart';
import 'package:pomodoro_app/presentation/settings/settings_providers.dart';

class AppearanceSettingsScreen extends ConsumerStatefulWidget {
  const AppearanceSettingsScreen({super.key});

  @override
  ConsumerState<AppearanceSettingsScreen> createState() =>
      _AppearanceSettingsScreenState();
}

class _AppearanceSettingsScreenState
    extends ConsumerState<AppearanceSettingsScreen> {
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
    final aodCaps = ref.watch(aodCapabilitiesProvider);
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.appearanceTitle)),
      body: settingsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => Center(child: Text(l10n.loadSettingsFailed)),
        data: (settings) => AbsorbPointer(
          absorbing: _saving,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(l10n.theme, style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              RadioGroup<AppTheme>(
                groupValue: settings.theme,
                onChanged: (theme) {
                  if (theme != null) {
                    _save(AppSettingsPatch(theme: theme));
                  }
                },
                child: Column(
                  children: AppTheme.values
                      .map(
                        (theme) => RadioListTile<AppTheme>(
                          title: Text(_themeLabel(theme, l10n)),
                          value: theme,
                        ),
                      )
                      .toList(),
                ),
              ),
              const Divider(height: 32),
              SwitchListTile(
                title: Text(l10n.alwaysOnDisplay),
                subtitle: Text(
                  aodCaps.alwaysOnDisplaySupported
                      ? l10n.aodEnabledDescription
                      : l10n.notSupportedOnDevice,
                ),
                value: settings.alwaysOnDisplay,
                onChanged: aodCaps.alwaysOnDisplaySupported
                    ? (value) => _save(AppSettingsPatch(alwaysOnDisplay: value))
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _themeLabel(AppTheme theme, AppLocalizations l10n) => switch (theme) {
  AppTheme.light => l10n.themeLight,
  AppTheme.dark => l10n.themeDark,
  AppTheme.system => l10n.themeFollowSystem,
};
