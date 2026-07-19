import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pomodoro_app/app/app.dart';
import 'package:pomodoro_app/platform/platform_bootstrap.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializePlatformServices();
  runApp(const ProviderScope(child: PomodoroApp()));
}
