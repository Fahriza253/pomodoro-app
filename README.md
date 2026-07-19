# Pomodoro App

Offline-first Pomodoro and Flexible timer for everyday focus work.

**Platform (v1.0):** **Android** is the supported release target. iOS builds exist with documented degradation (Focus and background notifications). Desktop and web are not first-class in this release.

## Pillars

| Pillar        | Role                                                                                                       |
| ------------- | ---------------------------------------------------------------------------------------------------------- |
| **Timer**     | **Pomodoro** (structured focus–rest cycles) and **Flexible** (open-ended sessions with interval reminders) |
| **Tag**       | Context labels (Study, Work, Sport) with per-mode timer presets                                            |
| **Statistic** | Session count and duration by period                                                                       |
| **Timeline**  | Chronological session history by date                                                                      |

## What sets it apart

- **Dual-mode** — Structured Pomodoro and open-ended Flexible in one app
- **Tag-driven config** — Different presets per activity context, not one global setting
- **Focus mode** — Strict / Whitelist / Loose on Android to cut distractions
- **Offline-first** — Local timer and data with no internet dependency

## Known limitations (v1.0)

- Manual past-session backfill is not included yet (see [CHANGELOG](CHANGELOG.md))
- iOS is secondary / best-effort compared to Android

## Get started

To build and run locally, see the [Build tutorial](docs/howto/build.md).

## Privacy

See [PRIVACY.md](PRIVACY.md) — local data, optional Usage Access for Focus, no telemetry in MVP.

## License

[MIT](LICENSE) — Copyright (c) 2026 Dafa Fawaz.
