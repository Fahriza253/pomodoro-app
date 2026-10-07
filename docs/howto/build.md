# Build

This page covers building and running the app locally on **Android**, plus [Linux desktop](#linux-desktop) and the [Windows installer](#windows-installer). iOS builds exist but are secondary and are not documented here.

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

## Linux desktop

Linux desktop is a secondary target. OS notifications, keep-screen-on, and Focus monitoring are not yet supported on desktop; the in-app Alert tone is the only alert.

In addition to the [Linux desktop requirements](https://docs.flutter.dev/platform-integration/linux/install-linux/install-linux-desktop) from Flutter, alert audio needs the GStreamer development packages (Debian/Ubuntu names):

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

The manual [Build Windows Release workflow](../../.github/workflows/windows-release.yml) produces an unsigned, current-user installer that runs on any Windows 10 or newer machine — no Visual C++ runtime or other prerequisites needed. The release MSVC runtime DLLs are bundled app-local next to the executable (a Microsoft-licensed deployment mode), so the app starts on a clean machine. Run the workflow from GitHub Actions, download the `windows-release` artifact, extract the artifact ZIP, and run `pomodoro_<version>_setup.exe`. The ZIP contains the installer, rather than a portable app folder; artifacts expire after seven days.

To build locally on Windows, install the [Flutter Windows prerequisites](https://docs.flutter.dev/platform-integration/windows/setup) and [Inno Setup 6.3 or newer in the 6.x series](https://jrsoftware.org/isdl.php). From the repository root in PowerShell:

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

The output is `build/windows/installer/pomodoro_<version>_setup.exe`. The version comes from the built executable's four-part Windows file version (for example, `1.2.0+3` in `pubspec.yaml` becomes `1.2.0.3`, producing `pomodoro_1.2.0.3_setup.exe`). The [installer script](../../windows/installer/release.iss) packages the complete x64 Release bundle, including Flutter assets, plugin libraries, and the app-local MSVC runtime.

Installation defaults to `%LOCALAPPDATA%\Programs\Pomodoro` without administrator access. It adds a Start Menu shortcut, offers an optional desktop shortcut, and registers **Pomodoro** in Windows' installed apps. Subsequent installers update the same installation. Close the app before upgrading. Existing portable folders are not removed.

The installed app retains the existing app identity and shares saved data with portable builds run by the same Windows user. Uninstalling removes installed files and shortcuts but preserves saved data. Avoid running installed and portable copies simultaneously during testing.

Debug builds are not packaged or distributed. `flutter build windows --debug` still works for local development, but the resulting exe needs the Visual C++ debug runtime from Visual Studio's C++ development tools; the regular Visual C++ Redistributable does not supply debug runtimes, and Microsoft does not license them for redistribution.

### Installer smoke check

On a Windows machine without any Visual C++ components installed:

1. Run the installer as a standard user. Confirm no administrator prompt and the default installation folder above.
2. Leave the desktop shortcut unchecked; launch **Pomodoro** from Start and confirm the timer and saved data load.
3. Close the app, run the installer again with the desktop shortcut selected, and confirm there is still one installed-app entry and existing data remains available.
4. Uninstall through Windows Settings. Confirm installed files and both shortcuts are removed.
5. Reinstall and verify the previously saved data is still available.

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
