import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pomodoro_app/domain/common/enums.dart';
import 'package:pomodoro_app/domain/common/result.dart';
import 'package:pomodoro_app/domain/settings/app_settings.dart';
import 'package:pomodoro_app/presentation/l10n/l10n_extensions.dart';
import 'package:pomodoro_app/presentation/settings/settings_error_messages.dart';
import 'package:pomodoro_app/presentation/settings/settings_providers.dart';
import 'package:pomodoro_app/app/timer_providers.dart';

class FocusSettingsScreen extends ConsumerStatefulWidget {
  const FocusSettingsScreen({super.key});

  @override
  ConsumerState<FocusSettingsScreen> createState() =>
      _FocusSettingsScreenState();
}

class _FocusSettingsScreenState extends ConsumerState<FocusSettingsScreen> {
  bool _saving = false;
  bool? _usageAccessGranted;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_usageAccessGranted == null) {
      _refreshUsageAccess();
    }
  }

  Future<void> _refreshUsageAccess() async {
    final adapter = ref.read(focusAdapterProvider);
    final granted = await adapter.hasUsageAccess();
    if (mounted) {
      setState(() => _usageAccessGranted = granted);
    }
  }

  Future<void> _save(AppSettingsPatch patch) async {
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
    final caps = ref.watch(focusCapabilitiesProvider);
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.focusModeTitle)),
      body: settingsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => Center(child: Text(l10n.loadSettingsFailed)),
        data: (settings) {
          final needsUsage = settings.focusMode != FocusMode.loose;
          final showPermissionBanner =
              needsUsage && _usageAccessGranted == false;

          return AbsorbPointer(
            absorbing: _saving,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (!caps.strictAvailable || !caps.whitelistAvailable)
                  Card(
                    color: Theme.of(context).colorScheme.errorContainer,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(
                        l10n.focusModeDegradedBanner,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onErrorContainer,
                        ),
                      ),
                    ),
                  ),
                RadioGroup<FocusMode>(
                  groupValue: settings.focusMode,
                  onChanged: (mode) {
                    if (mode != null) {
                      _save(AppSettingsPatch(focusMode: mode));
                    }
                  },
                  child: Column(
                    children: [
                      _ModeTile(
                        title: l10n.focusLoose,
                        subtitle: l10n.focusLooseSubtitle,
                        mode: FocusMode.loose,
                        enabled: true,
                      ),
                      _ModeTile(
                        title: l10n.focusStrict,
                        subtitle: l10n.focusStrictSubtitle,
                        mode: FocusMode.strict,
                        enabled: caps.strictAvailable,
                      ),
                      _ModeTile(
                        title: l10n.focusWhitelist,
                        subtitle: l10n.focusWhitelistSubtitle,
                        mode: FocusMode.whitelist,
                        enabled: caps.whitelistAvailable,
                      ),
                    ],
                  ),
                ),
                if (showPermissionBanner) ...[
                  const SizedBox(height: 16),
                  Card(
                    color: Theme.of(context).colorScheme.tertiaryContainer,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.warning_amber_rounded,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onTertiaryContainer,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  l10n.usageAccessRequired,
                                  style: TextStyle(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onTertiaryContainer,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          FilledButton.tonal(
                            onPressed: () async {
                              await ref
                                  .read(focusAdapterProvider)
                                  .openUsageAccessSettings();
                            },
                            child: Text(l10n.openSettings),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                Text(
                  l10n.violationThreshold,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<int>(
                  initialValue: settings.focusViolationThresholdSec,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    labelText: l10n.seconds,
                  ),
                  items: const [3, 5, 10, 15, 30, 60]
                      .map(
                        (sec) => DropdownMenuItem(
                          value: sec,
                          child: Text(l10n.secondsCount(sec)),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      _save(
                        AppSettingsPatch(focusViolationThresholdSec: value),
                      );
                    }
                  },
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: () => context.push('/settings/focus/whitelist'),
                  icon: const Icon(Icons.list_alt),
                  label: Text(l10n.manageWhitelist),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ModeTile extends StatelessWidget {
  const _ModeTile({
    required this.title,
    required this.subtitle,
    required this.mode,
    required this.enabled,
  });

  final String title;
  final String subtitle;
  final FocusMode mode;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final subtitleText = enabled ? subtitle : context.l10n.notAvailableOnDevice;
    return Card(
      child: RadioListTile<FocusMode>(
        title: Text(title),
        subtitle: Text(subtitleText),
        value: mode,
        enabled: enabled,
      ),
    );
  }
}
