import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pomodoro_app/domain/common/enums.dart';
import 'package:pomodoro_app/domain/settings/alert_tone_catalog.dart';
import 'package:pomodoro_app/domain/settings/app_settings.dart';
import 'package:pomodoro_app/l10n/app_localizations.dart';
import 'package:pomodoro_app/presentation/l10n/l10n_extensions.dart';
import 'package:pomodoro_app/presentation/settings/settings_providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(appSettingsStreamProvider);
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: settingsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 48),
                const SizedBox(height: 12),
                Text(
                  l10n.loadSettingsFailed,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                FilledButton(
                  onPressed: () => ref.invalidate(appSettingsStreamProvider),
                  child: Text(l10n.tryAgain),
                ),
              ],
            ),
          ),
        ),
        data: (settings) => ListView(
          children: [
            _SectionHeader(title: l10n.settingsSectionAlert.toUpperCase()),
            _SettingsTile(
              title: l10n.alertTones,
              subtitle: _alertTonesSummary(settings, l10n),
              onTap: () => context.push('/settings/alert'),
            ),
            _SectionHeader(title: l10n.settingsSectionFocus.toUpperCase()),
            _SettingsTile(
              title: l10n.focusMode,
              subtitle: _focusModeLabel(settings.focusMode, l10n),
              onTap: () => context.push('/settings/focus'),
            ),
            _SettingsTile(
              title: l10n.whitelistApps,
              subtitle: l10n.appCount(settings.whitelist.length),
              onTap: () => context.push('/settings/focus/whitelist'),
            ),
            _SectionHeader(
              title: l10n.settingsSectionAppearance.toUpperCase(),
            ),
            _SettingsTile(
              title: l10n.themeAndDisplay,
              subtitle: l10n.themeAodSummary(
                _themeLabel(settings.theme, l10n),
                settings.alwaysOnDisplay ? l10n.enabled : l10n.disabled,
              ),
              onTap: () => context.push('/settings/appearance'),
            ),
            _SectionHeader(
              title: l10n.settingsSectionTimeLanguage.toUpperCase(),
            ),
            _SettingsTile(
              title: l10n.timeAndLanguage,
              subtitle:
                  '${_languageLabel(settings.language, l10n)} · '
                  '${_timeFormatLabel(settings.timeFormat, l10n)} · '
                  '${_weekStartLabel(settings.weekStartDay, l10n)}',
              onTap: () => context.push('/settings/time'),
            ),
            _SectionHeader(title: l10n.settingsSectionStatistic.toUpperCase()),
            _SettingsTile(
              title: l10n.statisticInclusion,
              subtitle: l10n.statisticInclusionSummary(
                settings.trackFailedSessions ? l10n.yes : l10n.no,
              ),
              onTap: () => context.push('/settings/statistics'),
            ),
            _SectionHeader(title: l10n.settingsSectionPlatform.toUpperCase()),
            _SettingsTile(
              title: l10n.platformAndBattery,
              subtitle: l10n.platformSubtitle,
              onTap: () => context.push('/settings/platform'),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}

String _focusModeLabel(FocusMode mode, AppLocalizations l10n) =>
    switch (mode) {
      FocusMode.loose => l10n.focusLoose,
      FocusMode.strict => l10n.focusStrict,
      FocusMode.whitelist => l10n.focusWhitelist,
    };

String _themeLabel(AppTheme theme, AppLocalizations l10n) => switch (theme) {
  AppTheme.light => l10n.themeLight,
  AppTheme.dark => l10n.themeDark,
  AppTheme.system => l10n.themeSystem,
};

String _languageLabel(String code, AppLocalizations l10n) => switch (code) {
  'id' => l10n.languageIndonesian,
  _ => l10n.languageEnglish,
};

String _timeFormatLabel(TimeFormat format, AppLocalizations l10n) =>
    switch (format) {
      TimeFormat.h12 => l10n.timeFormat12h,
      TimeFormat.h24 => l10n.timeFormat24h,
    };

// ponytail: weekStartDay is validated to 0-6, but the settings UI only ever
// writes 0 or 1. Days 2-6 have no ARB copy — fall back to the raw number.
String _weekStartLabel(int day, AppLocalizations l10n) => switch (day) {
  0 => l10n.weekStartSunday,
  1 => l10n.weekStartMonday,
  _ => '$day',
};

String _alertTonesSummary(AppSettings settings, AppLocalizations l10n) =>
    l10n.alertTonesSummary(
      AlertToneCatalog.label(settings.alertToneFocusSuccess),
      AlertToneCatalog.label(settings.alertToneBreakOver),
    );
