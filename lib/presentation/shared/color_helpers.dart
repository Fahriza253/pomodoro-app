import 'package:flutter/material.dart';

/// Parses a `#RRGGBB` or `RRGGBB` hex string. Returns null if invalid.
Color? parseHexColor(String hex) {
  final cleaned = hex.replaceFirst('#', '');
  if (cleaned.length != 6) {
    return null;
  }
  final value = int.tryParse(cleaned, radix: 16);
  if (value == null) {
    return null;
  }
  return Color(0xFF000000 | value);
}

/// Like [parseHexColor], but returns [fallback] when the hex is invalid.
Color parseHexColorOr(String hex, Color fallback) =>
    parseHexColor(hex) ?? fallback;
