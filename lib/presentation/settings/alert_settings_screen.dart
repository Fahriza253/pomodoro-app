import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pomodoro_app/app/timer_providers.dart';
import 'package:pomodoro_app/domain/common/result.dart';
import 'package:pomodoro_app/domain/settings/alert_tone_catalog.dart';
import 'package:pomodoro_app/domain/settings/app_settings.dart';
import 'package:pomodoro_app/presentation/l10n/l10n_extensions.dart';
import 'package:pomodoro_app/presentation/settings/settings_error_messages.dart';
import 'package:pomodoro_app/presentation/settings/settings_providers.dart';

class AlertSettingsScreen extends ConsumerStatefulWidget {
  const AlertSettingsScreen({super.key});

  @override
  ConsumerState<AlertSettingsScreen> createState() =>
      _AlertSettingsScreenState();
}

class _AlertSettingsScreenState extends ConsumerState<AlertSettingsScreen> {
  static const _previewCooldown = Duration(milliseconds: 500);

  bool _saving = false;
  bool _previewBusy = false;
  DateTime? _lastPreviewAt;

  Future<void> _onFocusSuccessTap(String tone, String current) async {
    if (tone != current) {
      await _save(AppSettingsPatch(alertToneFocusSuccess: tone));
    }
    await _preview(tone);
  }

  Future<void> _onBreakOverTap(String tone, String current) async {
    if (tone != current) {
      await _save(AppSettingsPatch(alertToneBreakOver: tone));
    }
    await _preview(tone);
  }

  Future<void> _onFocusFailureTap() async {
    await _preview(AlertToneCatalog.failureWrong);
  }

  /// Rate-limited test play — ignores rapid re-taps so AudioPlayer isn't flooded.
  Future<void> _preview(String tone) async {
    final now = DateTime.now();
    if (_previewBusy) {
      return;
    }
    if (_lastPreviewAt != null &&
        now.difference(_lastPreviewAt!) < _previewCooldown) {
      return;
    }
    _previewBusy = true;
    _lastPreviewAt = now;
    try {
      await ref.read(alertSoundAdapterProvider).play(tone);
    } finally {
      if (mounted) {
        _previewBusy = false;
      } else {
        _previewBusy = false;
      }
    }
  }

  Future<void> _save(AppSettingsPatch patch) async {
    if (_saving) {
      return;
    }
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
      appBar: AppBar(title: Text(l10n.alertTonesTitle)),
      body: settingsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => Center(child: Text(l10n.loadSettingsFailed)),
        data: (settings) => ListView(
          padding: const EdgeInsets.only(bottom: 24),
          children: [
            _sectionHeader(context, l10n.focusComplete),
            RadioGroup<String>(
              groupValue: settings.alertToneFocusSuccess,
              onChanged: (_) {},
              child: Column(
                children: AlertToneCatalog.sharedSegmentToneIds.map((tone) {
                  return _toneTile(
                    tone: tone,
                    onTap: _saving
                        ? null
                        : () => _onFocusSuccessTap(
                            tone,
                            settings.alertToneFocusSuccess,
                          ),
                  );
                }).toList(),
              ),
            ),
            _sectionHeader(context, l10n.breakComplete),
            RadioGroup<String>(
              groupValue: settings.alertToneBreakOver,
              onChanged: (_) {},
              child: Column(
                children: AlertToneCatalog.sharedSegmentToneIds.map((tone) {
                  return _toneTile(
                    tone: tone,
                    onTap: _saving
                        ? null
                        : () => _onBreakOverTap(
                            tone,
                            settings.alertToneBreakOver,
                          ),
                  );
                }).toList(),
              ),
            ),
            _sectionHeader(context, l10n.focusFailed),
            RadioGroup<String>(
              groupValue: settings.alertToneFocusFailure,
              onChanged: (_) {},
              child: _toneTile(
                tone: AlertToneCatalog.failureWrong,
                onTap: _saving ? null : _onFocusFailureTap,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Text(
                l10n.alertTonePreviewHint,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _toneTile({required String tone, required VoidCallback? onTap}) {
    return ListTile(
      leading: Radio<String>(value: tone),
      title: Text(AlertToneCatalog.label(tone)),
      onTap: onTap,
    );
  }
}
