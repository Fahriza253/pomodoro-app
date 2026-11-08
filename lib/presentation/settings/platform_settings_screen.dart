import 'package:flutter/material.dart';
import 'package:pomodoro_app/presentation/shared/phosphor_icon_data.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pomodoro_app/platform/battery/battery_guidance.dart';
import 'package:pomodoro_app/presentation/l10n/l10n_extensions.dart';
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
          if (caps.notifications.scheduledSegmentEnd)
            _CapabilityTile(
              title: l10n.segmentNotifications,
              detail: caps.notifications.deepLinkOnTap
                  ? l10n.notificationDeepLinkAvailable
                  : l10n.deepLinkUnavailable,
            ),
          if (caps.notifications.reminders)
            _CapabilityTile(title: l10n.flexibleReminders),
          if (caps.focus.strictAvailable)
            _CapabilityTile(title: '${l10n.segmentFocus} ${l10n.focusStrict}'),
          if (caps.focus.whitelistAvailable)
            _CapabilityTile(
              title: '${l10n.segmentFocus} ${l10n.focusWhitelist}',
            ),
          if (caps.aod.alwaysOnDisplaySupported)
            _CapabilityTile(title: l10n.alwaysOnDisplay),
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
    this.detail,
  });

  final String title;
  final String? detail;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        PresentationPhosphorIcons.checkCircle(filled: true),
        color: Theme.of(context).colorScheme.primary,
      ),
      title: Text(title),
      subtitle: detail != null ? Text(detail!) : null,
    );
  }
}
