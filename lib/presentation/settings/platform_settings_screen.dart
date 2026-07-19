import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pomodoro_app/platform/battery/battery_guidance.dart';
import 'package:pomodoro_app/presentation/l10n/l10n_extensions.dart';
import 'package:pomodoro_app/presentation/settings/platform_degraded_note_l10n.dart';
import 'package:pomodoro_app/presentation/settings/platform_providers.dart';

class PlatformSettingsScreen extends ConsumerWidget {
  const PlatformSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final caps = ref.watch(platformCapabilitiesProvider);
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.platformBatteryTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            l10n.platformLabel(caps.platformLabel),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          _CapabilityTile(
            title: l10n.segmentNotifications,
            supported: caps.notifications.scheduledSegmentEnd,
            detail: caps.notifications.deepLinkOnTap
                ? l10n.notificationDeepLinkAvailable
                : l10n.deepLinkUnavailable,
          ),
          _CapabilityTile(
            title: l10n.flexibleReminders,
            supported: caps.notifications.reminders,
          ),
          _CapabilityTile(
            title: '${l10n.segmentFocus} ${l10n.focusStrict}',
            supported: caps.focus.strictAvailable,
          ),
          _CapabilityTile(
            title: '${l10n.segmentFocus} ${l10n.focusWhitelist}',
            supported: caps.focus.whitelistAvailable,
          ),
          _CapabilityTile(
            title: l10n.alwaysOnDisplay,
            supported: caps.aod.alwaysOnDisplaySupported,
          ),
          if (caps.degradedNotes.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              l10n.platformNotes,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            ...caps.degradedNotes.map(
              (note) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.info_outline, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(platformDegradedNoteMessage(note, l10n)),
                    ),
                  ],
                ),
              ),
            ),
          ],
          if (BatteryGuidance.isAndroid) ...[
            const Divider(height: 32),
            Text(
              l10n.batteryOptimization,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            Text(l10n.batteryOptimizationBody),
            const SizedBox(height: 12),
            FilledButton.tonal(
              onPressed: BatteryGuidance.openBatterySettings,
              child: Text(l10n.openBatterySettings),
            ),
          ],
        ],
      ),
    );
  }
}

class _CapabilityTile extends StatelessWidget {
  const _CapabilityTile({
    required this.title,
    required this.supported,
    this.detail,
  });

  final String title;
  final bool supported;
  final String? detail;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        supported ? Icons.check_circle : Icons.remove_circle_outline,
        color: supported ? Colors.green : Theme.of(context).colorScheme.outline,
      ),
      title: Text(title),
      subtitle: detail != null ? Text(detail!) : null,
    );
  }
}
