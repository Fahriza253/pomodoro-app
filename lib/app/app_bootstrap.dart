import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pomodoro_app/app/providers.dart';
import 'package:pomodoro_app/application/bootstrap/bootstrap_gate.dart';

/// Splash marketing beat (2000 ms or immediate when reduced motion).
final marketingBeatCompleteProvider = StateProvider<bool>((ref) => false);

/// Bootstrap gate output: single seam for shell, router redirect, and tests.
final bootstrapPhaseProvider = Provider<BootstrapPhase>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return BootstrapGate.phase(dbHasError: db.hasError, dbHasValue: db.hasValue);
});

final bootstrapReadyProvider = Provider<bool>(
  (ref) => ref.watch(bootstrapPhaseProvider) == BootstrapPhase.ready,
);

void markMarketingBeatComplete(WidgetRef ref) {
  if (ref.read(marketingBeatCompleteProvider)) {
    return;
  }
  ref.read(marketingBeatCompleteProvider.notifier).state = true;
}
