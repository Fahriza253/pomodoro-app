import 'package:flutter/material.dart';

/// Brand splash while the local database opens / seeds.
///
/// Must be placed under a parent [MaterialApp] (see [PomodoroApp] loading branch).
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  static const seed = Color(0xFF6366F1);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image(
              image: AssetImage('assets/icon/icon.png'),
              width: 72,
              height: 72,
            ),
            SizedBox(height: 16),
            Text(
              'Pomodoro',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
            ),
            SizedBox(height: 32),
            SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2.5, color: seed),
            ),
          ],
        ),
      ),
    );
  }
}
