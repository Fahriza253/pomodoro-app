# Build

This page covers the local build flow for Android, plus the secondary desktop targets for [Linux](#linux-desktop) and the packaged [Windows installer](#windows-installer). iOS builds exist, but they are not the main local workflow and are not documented here.

## Prerequisites

Before starting, confirm the following:

- [Flutter](https://docs.flutter.dev/get-started/install) is installed, with a Dart SDK that satisfies the constraint in `pubspec.yaml`
- Android Studio or the Android SDK is available
- A device or emulator is available to run the app

Run all commands from the repository root. Check the toolchain first:

```bash
flutter doctor
```

## Android: build and run

Use this flow for the default local development target:

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run
```

A few details matter:

- `flutter run` uses a plugged-in device or running emulator. If more than one device is attached, Flutter prompts you to choose one.
- `build_runner` generates Drift and related code.
- Re-run `build_runner` after schema changes or other code generation updates.

## Linux desktop

Linux desktop is a secondary target. OS notifications, keep-screen-on, and Focus monitoring are not yet supported there; the in-app Alert tone is the only alert.

Install the extra audio dependency required for desktop alerts on Debian/Ubuntu:

```bash
sudo apt install libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev
```

Then build and run:

```bash
flutter build linux --debug
flutter run -d linux
```

The database is stored at `~/.local/share/com.dpzstudio.pomodoro_app/pomodoro.sqlite`.

## Windows installer

There are two practical paths:

1. Use the manual [Build Windows Release workflow](../../.github/workflows/windows-release.yml) to produce the packaged installer.
2. Build the Windows release locally if you need to validate the packaging flow.

### Packaged release from GitHub Actions

The workflow produces an unsigned, current-user installer that runs on Windows 10 or newer without any Visual C++ runtime prerequisites. The release MSVC runtime DLLs are bundled app-local next to the executable, so the app starts on a clean machine.

The workflow steps are:

- run the workflow from GitHub Actions
- download the `windows-release` artifact
- extract the ZIP
- run `pomodoro_<version>_setup.exe`

The ZIP contains the installer, not a portable app folder, and artifacts expire after seven days.

### Local Windows build

Install the [Flutter Windows prerequisites](https://docs.flutter.dev/platform-integration/windows/setup) and [Inno Setup 6.3 or newer in the 6.x series](https://jrsoftware.org/isdl.php). Then run the following from the repository root in PowerShell:

```powershell
flutter pub get
dart run build_runner build
flutter analyze --fatal-infos --fatal-warnings
flutter build windows --release
# Bundles app-local MSVC CRT: newest Redist\MSVC\v*\x64\Microsoft.VC*.CRT that exists
# (skips empty v145 on VS 2026 runners), else VC\Tools\MSVC\*\bin\Hostx64\x64.
./windows/ci/bundle_msvc_runtime.ps1
& "${env:ProgramFiles(x86)}\Inno Setup 6\ISCC.exe" windows/installer/release.iss
if ($LASTEXITCODE -ne 0) { throw "Installer compilation failed" }
```

The output is `build/windows/installer/pomodoro_<version>_setup.exe`.

The version is derived from the executable's four-part Windows file version. For example, `1.2.0+3` in `pubspec.yaml` becomes `1.2.0.3`, producing `pomodoro_1.2.0.3_setup.exe`. The [installer script](../../windows/installer/release.iss) packages the complete x64 Release bundle, including Flutter assets, plugin libraries, and the app-local MSVC runtime.

### Installer behavior and edge cases

- Installation defaults to `%LOCALAPPDATA%\Programs\Pomodoro` without administrator access.
- It adds a Start Menu shortcut, offers an optional desktop shortcut, and registers **Pomodoro** in Windows' installed apps.
- Subsequent installers update the same installation.
- Close the app before upgrading; existing portable folders are not removed.
- The installed app keeps the same app identity and shares saved data with portable builds run by the same Windows user.
- Uninstalling removes installed files and shortcuts while preserving saved data.
- Do not run installed and portable copies simultaneously during testing.
- Debug builds are not packaged or distributed. `flutter build windows --debug` still works for local development, but the resulting executable needs the Visual C++ debug runtime from Visual Studio's C++ development tools. The regular Visual C++ Redistributable does not provide debug runtimes, and Microsoft does not license them for redistribution.

### Installer smoke check

On a Windows machine without any Visual C++ components installed:

1. Run the installer as a standard user. Confirm there is no administrator prompt and the default installation folder above.
2. Leave the desktop shortcut unchecked; launch **Pomodoro** from Start and confirm the timer and saved data load.
3. Close the app, run the installer again with the desktop shortcut selected, and confirm there is still one installed-app entry and the existing data remains available.
4. Uninstall through Windows Settings and confirm the installed files and both shortcuts are removed.
5. Reinstall and verify the previously saved data is still available.

## Verify

After a successful run, these checks are a useful sanity pass before contributing:

```bash
flutter analyze
flutter test
```

## Optional: short debug tag

For manual QA, the app can upsert a reserved Debug Tag with 5-second durations. This is not intended for normal day-to-day use.

```bash
flutter run --dart-define=DEBUG_SHORT_TAG=true
```
