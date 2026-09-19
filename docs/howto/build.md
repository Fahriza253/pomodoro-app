# Build

This page covers building and running the app locally on **Android**. iOS builds exist but are secondary and are not documented here.

## Prerequisites

Before starting, confirm the following:

- [Flutter](https://docs.flutter.dev/get-started/install) is installed, with a Dart SDK that satisfies the constraint in `pubspec.yaml`
- Android Studio (or the Android SDK) is available
- A device or emulator is available to run the app

Run all commands from the repository root. Check the toolchain with:

```bash
flutter doctor
```

## Build and run

Fetch dependencies, generate code, then launch the app:

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run
```

`flutter run` uses a running emulator or a plugged-in device. If more than one is attached, Flutter prompts for a selection.

`build_runner` generates Drift and related code.

> **Note:** Run `build_runner` again after schema changes or other codegen updates.

## Verify

After a successful run, these optional checks are a useful sanity check before contributing:

```bash
flutter analyze
flutter test
```

## Optional: short debug Tag

For manual QA, the app can upsert a reserved Debug Tag with 5-second durations. This is not intended for normal day-to-day use.

```bash
flutter run --dart-define=DEBUG_SHORT_TAG=true
```
