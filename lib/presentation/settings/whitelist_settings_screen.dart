import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pomodoro_app/app/timer_providers.dart';
import 'package:pomodoro_app/domain/common/result.dart';
import 'package:pomodoro_app/domain/settings/app_settings.dart';
import 'package:pomodoro_app/platform/focus/focus_adapter.dart';
import 'package:pomodoro_app/presentation/l10n/l10n_extensions.dart';
import 'package:pomodoro_app/presentation/settings/settings_error_messages.dart';
import 'package:pomodoro_app/presentation/settings/settings_providers.dart';

class WhitelistSettingsScreen extends ConsumerStatefulWidget {
  const WhitelistSettingsScreen({super.key});

  @override
  ConsumerState<WhitelistSettingsScreen> createState() =>
      _WhitelistSettingsScreenState();
}

class _WhitelistSettingsScreenState
    extends ConsumerState<WhitelistSettingsScreen> {
  bool _saving = false;
  List<InstalledAppInfo>? _installedApps;

  @override
  void initState() {
    super.initState();
    _loadInstalledApps();
  }

  Future<void> _loadInstalledApps() async {
    final apps = await ref.read(focusAdapterProvider).listInstalledApps();
    if (mounted) {
      setState(() => _installedApps = apps);
    }
  }

  Future<void> _saveWhitelist(List<String> whitelist) async {
    setState(() => _saving = true);
    final result = await ref
        .read(settingsUseCasesProvider)
        .updateSettings(AppSettingsPatch(whitelist: whitelist));
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

  Future<void> _addApp(List<String> current) async {
    final apps = _installedApps;
    if (apps == null || apps.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.installedAppsUnavailable)),
      );
      return;
    }

    final selected = await showModalBottomSheet<InstalledAppInfo>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.7,
          builder: (context, scrollController) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    context.l10n.selectApp,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: apps.length,
                    itemBuilder: (context, index) {
                      final app = apps[index];
                      final already = current.contains(app.packageName);
                      return ListTile(
                        title: Text(app.label),
                        subtitle: Text(app.packageName),
                        enabled: !already,
                        onTap: already
                            ? null
                            : () => Navigator.of(context).pop(app),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    if (selected == null) return;
    await _saveWhitelist([...current, selected.packageName]);
  }

  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(appSettingsStreamProvider);
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.whitelistAppsTitle)),
      body: settingsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => Center(child: Text(l10n.loadSettingsFailed)),
        data: (settings) {
          final whitelist = settings.whitelist;
          final labelByPackage = {
            for (final app in _installedApps ?? <InstalledAppInfo>[])
              app.packageName: app.label,
          };

          return AbsorbPointer(
            absorbing: _saving,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: FilledButton.icon(
                    onPressed: () => _addApp(whitelist),
                    icon: const Icon(Icons.add),
                    label: Text(l10n.addApp),
                  ),
                ),
                Expanded(
                  child: whitelist.isEmpty
                      ? Center(child: Text(l10n.whitelistEmpty))
                      : ListView.builder(
                          itemCount: whitelist.length,
                          itemBuilder: (context, index) {
                            final package = whitelist[index];
                            final label = labelByPackage[package] ?? package;
                            return Card(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 4,
                              ),
                              child: ListTile(
                                title: Text(label),
                                subtitle: Text(package),
                                trailing: IconButton(
                                  icon: const Icon(Icons.close),
                                  onPressed: () {
                                    final next = [...whitelist]
                                      ..removeAt(index);
                                    _saveWhitelist(next);
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    l10n.whitelistOnlyWhenActive,
                    style: Theme.of(context).textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
