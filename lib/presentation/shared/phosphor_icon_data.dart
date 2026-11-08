import 'package:flutter/widgets.dart';

/// Builds [IconData] for icons bundled in the `phosphor_flutter` package.
///
/// We avoid importing generated `PhosphorIcons*` symbols because `phosphor_flutter`
/// 2.1.0 subclasses final [IconData] and does not compile on Dart 3.12+ yet.
IconData phosphorIcon(int codePoint, {required bool filled}) {
  return IconData(
    codePoint,
    fontFamily: filled ? 'PhosphorFill' : 'PhosphorRegular',
    fontPackage: 'phosphor_flutter',
    matchTextDirection: true,
  );
}

/// Code points for bottom navigation (MASTER mapping).
abstract final class HomeShellPhosphorIcons {
  static const timerCodePoint = 0xe492;
  static const clockCodePoint = 0xe19a;
  static const chartBarCodePoint = 0xe150;
  static const gearCodePoint = 0xe270;

  static IconData timer({required bool selected}) =>
      phosphorIcon(timerCodePoint, filled: selected);

  static IconData clock({required bool selected}) =>
      phosphorIcon(clockCodePoint, filled: selected);

  static IconData chartBar({required bool selected}) =>
      phosphorIcon(chartBarCodePoint, filled: selected);

  static IconData gear({required bool selected}) =>
      phosphorIcon(gearCodePoint, filled: selected);
}

/// Phosphor-glyphs for screens under `lib/presentation/` (regular default).
abstract final class PresentationPhosphorIcons {
  static const _pkg = 'phosphor_flutter';
  static const _regular = 'PhosphorRegular';
  static const _fill = 'PhosphorFill';

  static const arrowLeft = IconData(
    0xe058,
    fontFamily: _regular,
    fontPackage: _pkg,
    matchTextDirection: true,
  );
  static const bellRinging = IconData(
    0xe5e8,
    fontFamily: _regular,
    fontPackage: _pkg,
    matchTextDirection: true,
  );
  static const calendarBlank = IconData(
    0xe10a,
    fontFamily: _regular,
    fontPackage: _pkg,
    matchTextDirection: true,
  );
  static const calendarX = IconData(
    0xe10c,
    fontFamily: _regular,
    fontPackage: _pkg,
    matchTextDirection: true,
  );
  static const caretDown = IconData(
    0xe136,
    fontFamily: _regular,
    fontPackage: _pkg,
    matchTextDirection: true,
  );
  static const caretRight = IconData(
    0xe13a,
    fontFamily: _regular,
    fontPackage: _pkg,
    matchTextDirection: true,
  );
  static const chartBar = IconData(
    0xe150,
    fontFamily: _regular,
    fontPackage: _pkg,
    matchTextDirection: true,
  );
  static const dotsSix = IconData(
    0xe794,
    fontFamily: _regular,
    fontPackage: _pkg,
    matchTextDirection: true,
  );
  static const dotsThree = IconData(
    0xe1fe,
    fontFamily: _regular,
    fontPackage: _pkg,
    matchTextDirection: true,
  );
  static const hourglass = IconData(
    0xe2b2,
    fontFamily: _regular,
    fontPackage: _pkg,
    matchTextDirection: true,
  );
  static const listBullets = IconData(
    0xe2f2,
    fontFamily: _regular,
    fontPackage: _pkg,
    matchTextDirection: true,
  );
  static const plus = IconData(
    0xe3d4,
    fontFamily: _regular,
    fontPackage: _pkg,
    matchTextDirection: true,
  );
  static const repeat = IconData(
    0xe3f6,
    fontFamily: _regular,
    fontPackage: _pkg,
    matchTextDirection: true,
  );
  static const skipForward = IconData(
    0xe5a6,
    fontFamily: _regular,
    fontPackage: _pkg,
    matchTextDirection: true,
  );
  static const stop = IconData(
    0xe46c,
    fontFamily: _regular,
    fontPackage: _pkg,
    matchTextDirection: true,
  );
  static const tag = IconData(
    0xe478,
    fontFamily: _regular,
    fontPackage: _pkg,
    matchTextDirection: true,
  );
  static const warning = IconData(
    0xe4e0,
    fontFamily: _regular,
    fontPackage: _pkg,
    matchTextDirection: true,
  );
  static const x = IconData(
    0xe4f6,
    fontFamily: _regular,
    fontPackage: _pkg,
    matchTextDirection: true,
  );

  static const checkCircleRegular = IconData(
    0xe184,
    fontFamily: _regular,
    fontPackage: _pkg,
    matchTextDirection: true,
  );
  static const checkCircleFill = IconData(
    0xe184,
    fontFamily: _fill,
    fontPackage: _pkg,
    matchTextDirection: true,
  );
  static IconData checkCircle({bool filled = false}) =>
      filled ? checkCircleFill : checkCircleRegular;

  static const pauseRegular = IconData(
    0xe39e,
    fontFamily: _regular,
    fontPackage: _pkg,
    matchTextDirection: true,
  );
  static const pauseFill = IconData(
    0xe39e,
    fontFamily: _fill,
    fontPackage: _pkg,
    matchTextDirection: true,
  );
  static IconData pause({bool filled = false}) =>
      filled ? pauseFill : pauseRegular;

  static const playRegular = IconData(
    0xe3d0,
    fontFamily: _regular,
    fontPackage: _pkg,
    matchTextDirection: true,
  );
  static const playFill = IconData(
    0xe3d0,
    fontFamily: _fill,
    fontPackage: _pkg,
    matchTextDirection: true,
  );
  static IconData play({bool filled = false}) =>
      filled ? playFill : playRegular;

  static const playCircleRegular = IconData(
    0xe3d2,
    fontFamily: _regular,
    fontPackage: _pkg,
    matchTextDirection: true,
  );
  static const playCircleFill = IconData(
    0xe3d2,
    fontFamily: _fill,
    fontPackage: _pkg,
    matchTextDirection: true,
  );
  static IconData playCircle({bool filled = false}) =>
      filled ? playCircleFill : playCircleRegular;

  static const warningCircleRegular = IconData(
    0xe4e2,
    fontFamily: _regular,
    fontPackage: _pkg,
    matchTextDirection: true,
  );
  static const warningCircleFill = IconData(
    0xe4e2,
    fontFamily: _fill,
    fontPackage: _pkg,
    matchTextDirection: true,
  );
  static IconData warningCircle({bool filled = false}) =>
      filled ? warningCircleFill : warningCircleRegular;
}
