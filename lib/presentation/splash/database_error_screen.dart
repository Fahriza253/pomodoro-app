import 'package:flutter/material.dart';
import 'package:pomodoro_app/l10n/app_localizations.dart';
import 'package:pomodoro_app/presentation/l10n/l10n_extensions.dart';

/// Friendly blocking error when local database init / seed fails.
///
/// Copy avoids technical jargon; retry re-attempts open + seed.
class DatabaseErrorScreen extends StatelessWidget {
  const DatabaseErrorScreen({required this.onRetry, super.key});

  final VoidCallback onRetry;

  static const _seed = Color(0xFF6366F1);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      locale: const Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: _seed),
        useMaterial3: true,
      ),
      home: _DatabaseErrorBody(onRetry: onRetry),
    );
  }
}

class _DatabaseErrorBody extends StatelessWidget {
  const _DatabaseErrorBody({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = context.l10n;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 360),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    size: 56,
                    color: scheme.error,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    l10n.databaseNotReadyTitle,
                    textAlign: TextAlign.center,
                    style: textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    l10n.databaseNotReadyBody,
                    textAlign: TextAlign.center,
                    style: textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF6B7280),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: onRetry,
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                      ),
                      child: Text(l10n.tryAgain),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
