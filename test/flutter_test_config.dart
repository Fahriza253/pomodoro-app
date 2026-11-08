import 'dart:async';

import 'package:google_fonts/google_fonts.dart';

/// Disables runtime font fetching so widget/unit tests stay offline.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  GoogleFonts.config.allowRuntimeFetching = false;
  await testMain();
}
