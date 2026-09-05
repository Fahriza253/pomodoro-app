import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pomodoro_app/domain/common/result.dart';
import 'package:pomodoro_app/domain/settings/app_settings.dart';
import 'package:pomodoro_app/presentation/l10n/l10n_extensions.dart';
import 'package:pomodoro_app/presentation/settings/settings_error_messages.dart';
import 'package:pomodoro_app/presentation/settings/settings_providers.dart';

/// Shared Alert Controls toggles (Settings + timer sheet). BR-SETTINGS-007.
class AlertControlsSection extends ConsumerStatefulWidget {
  const AlertControlsSection({
    this.dense = false,
    super.key,
  });

  final bool dense;

  @override
  ConsumerState<AlertControlsSection> createState() =>
      _AlertControlsSectionState();
}

class _AlertControlsSectionState extends ConsumerState<AlertControlsSection> {
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
    final flashCapable =
        ref.watch(flashCapabilitiesProvider).supported;
    final l10n = context.l10n;

    return settingsAsync.when(
      loading: () => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          children: List.generate(
            3,
            (_) => const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: ColoredBox(
                color: Color(0x11000000),
                child: SizedBox(height: 48, width: double.infinity),
              ),
            ),
          ),
        ),
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
        final children = <Widget>[
          if (!widget.dense) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: Text(
                l10n.alertControlsHint,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ],
          SwitchListTile(
            title: Text(l10n.alertHaptic),
            value: settings.alertHapticEnabled,
            onChanged: _saving
                ? null
                : (v) => _save(AppSettingsPatch(alertHapticEnabled: v)),
          ),
          SwitchListTile(
            title: Text(l10n.alertSoundMute),
            value: settings.alertSoundMuted,
            onChanged: _saving
                ? null
                : (v) => _save(AppSettingsPatch(alertSoundMuted: v)),
          ),
          SwitchListTile(
            title: Text(l10n.alertFlash),
            subtitle: flashCapable ? null : Text(l10n.alertFlashUnsupported),
            value: settings.alertFlashEnabled && flashCapable,
            onChanged: !flashCapable || _saving
                ? null
                : (v) => _save(AppSettingsPatch(alertFlashEnabled: v)),
          ),
        ];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: children,
        );
      },
    );
  }
}

Future<void> showAlertControlsSheet(BuildContext context) {
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
                  l10n.alertControlsSheetTitle,
                  style: Theme.of(sheetContext).textTheme.titleMedium,
                ),
              ),
              const AlertControlsSection(dense: true),
            ],
          ),
        ),
      );
    },
  );
}
