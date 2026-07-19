import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pomodoro_app/app/timer_providers.dart';
import 'package:pomodoro_app/platform/platform_capabilities.dart';

final platformCapabilitiesProvider = Provider<PlatformCapabilitiesSnapshot>((
  ref,
) {
  return buildPlatformCapabilities(
    focusAdapter: ref.watch(focusAdapterProvider),
    notificationAdapter: ref.watch(notificationAdapterProvider),
    aodAdapter: ref.watch(aodAdapterProvider),
  );
});
