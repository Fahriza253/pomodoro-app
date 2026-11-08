# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/).

## [1.4.0] - 2026-11-08

### Added

- Shared colors on the timer ring and session UI for focus, rest, and flexible segments
- A fixed chart color palette for tag breakdown on Statistic instead of per-tag colors
- Refreshed icons on bottom navigation and main screens
- Inter typography for English and Indonesian

### Changed

- Tags keep only a name and presets; color pickers and saved tag colors are removed on upgrade
- Active sessions use a segment-colored progress ring and neutral tag chips
- Timeline and Statistic show tag names without color dots
- Settings lists only options the device supports instead of warning cards for missing features
- Splash and timer motion follow design timings; session-complete celebration respects reduced motion and stops after 1.5 seconds

### Removed

- Tag color dots across the app
- Settings degradation banners for unsupported platform features

### Known limitations (still true in 1.4.0)

- You still cannot add past sessions by hand
- On iOS, focus modes and background behavior remain limited compared with Android
- On desktop, in-app alert sound only; OS-level alert parity is not shipped
- Local data is not encrypted at rest
- Vibration alerts remain unreliable in the foreground and background

## [1.3.0] — 2026-10-07

### Added

- App-wide **Light** / **Dark** / **System** theming with Material 3 (`AppTheme`, persisted in Settings)
- Pomodoro **3-2-1 pre-start** countdown before a focus Session starts (skip supported)

### Changed

- Pre-start countdown is driven by `TimerCoordinator` and shown on `TimerViewState` (not presentation-only timers)

### Fixed

- Windows release packaging: Inno Setup installer ships with an app-local MSVC runtime so the app runs without a separate Visual C++ install

### Known limitations (still true in 1.3.0)

- **Manual duration backfill (UC-08)** — not shipped
- **iOS** — still secondary / degraded vs Android (Focus Strict/Whitelist and background parity)
- **Desktop** — secondary / degraded (in-app Alert tone only)
- Local database is **not encrypted at rest**
- **Haptic alert** — still unreliable in foreground and background

## [1.2.0] — 2026-09-30

### Added

- Session complete celebration for Pomodoro: animated “You did it!” screen with **Start New Session** (same Tag, latest config) or **Back to Home**
- Linux and Windows desktop builds (secondary target) — data stored in the platform app-data folder; no OS notifications, keep-screen-on, or Focus monitoring on desktop

### Changed

- Timer internals restructured for reliability (session lifecycle, side effects, and Segment writes split into separate components); no behaviour change intended

### Known limitations (still true in 1.2.0)

- **Manual duration backfill (UC-08)** — not shipped
- **iOS** — still secondary / degraded vs Android (Focus Strict/Whitelist and background parity)
- **Desktop** — secondary / degraded (in-app Alert tone only)
- Local database is **not encrypted at rest**
- **Haptic alert** — still unreliable in foreground and background

## [1.1.0] — 2026-09-05

### Fixed

- Segment-end alerts deliver once: in-app only while the UI is visible; one OS notification when backgrounded; no second post or in-app replay on resume
- Focus-failure and Flexible reminder alerts follow the same once-only channel rule
- Tag mode config save/validation (slider grid, reminder bounds, clearer validator copy)
- Timeline Pomodoro session detail shows correct “Cycle X of Y”

### Known limitations (still true in 1.1.0)

- **Manual duration backfill (UC-08)** — not shipped
- **iOS** — still secondary / degraded vs Android (Focus Strict/Whitelist and background parity)
- Local database is **not encrypted at rest**
- **Haptic alert** — still unreliable in foreground and background

## [1.0.1] — 2026-08-01

### Added

- iOS Live Activities for the running timer (`PomodoroTimerWidget`, `live_activities`)
- Alert Settings controls: haptic, mute, and flash modalities

### Fixed

- Live Activities / running-timer notification sync on iOS

## [1.0.0] — 2026-07-19

First public Android release (Play Store target).

### Added

- Pomodoro and Flexible timer modes with Tag-driven presets
- Pause / resume / stop with wall-clock background timing
- Focus modes (Strict / Whitelist / Loose) on Android
- Statistics by period and Timeline session history
- Settings: alerts, appearance, language (EN/ID), AOD, time definition
- Offline-first local SQLite storage; no accounts or telemetry

### Known limitations (v1.0)

- **Manual duration backfill (UC-08)** — not shipped. Timeline does not offer adding past sessions by hand; the feature is deferred to a later release.
- **iOS** — build scaffold only; Focus Strict/Whitelist and background notifications are degraded vs Android. Not an equal App Store peer in this release.
- **Desktop / web** — not first-class targets in this release.
- Local database is **not encrypted at rest**.

### Platform

- Primary: **Android**
- Secondary: iOS (best-effort / degraded)
