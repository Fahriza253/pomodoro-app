# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/).

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
- Local database is **not encrypted at rest** (see [PRIVACY.md](PRIVACY.md)).

### Platform

- Primary: **Android**
- Secondary: iOS (best-effort / degraded)
