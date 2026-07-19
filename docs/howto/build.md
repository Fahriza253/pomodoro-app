# Build

How to build and run this project locally on **Android** (the supported v1.0 platform).

## Prerequisites

- [Flutter](https://docs.flutter.dev/get-started/install) (Dart SDK compatible with `^3.12.2` — see `pubspec.yaml`)
- Android Studio / SDK, plus a device or emulator
- From the repo root, confirm the toolchain:

```bash
flutter doctor
```

## Build & run (Android)

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run
```

`build_runner` generates Drift (and related) code. Run it again after schema or other codegen changes.

## Verify

```bash
flutter analyze
flutter test
```
