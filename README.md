# Pomodoro App

An offline-first Pomodoro and Flexible timer for everyday focus work.

**Platform (v1.0):** Android is the supported release target. iOS builds exist, but Focus mode and background notifications are degraded there. Desktop and web are not first-class targets in this release.

## Pillars

| Pillar        | Role                                                                                                           |
| ------------- | -------------------------------------------------------------------------------------------------------------- |
| **Timer**     | **Pomodoro** (structured focus and rest cycles) and **Flexible** (open-ended sessions with interval reminders) |
| **Tag**       | Context labels (Study, Work, Sport), each with its own timer presets per mode                                  |
| **Statistic** | Session count and total duration, grouped by period                                                            |
| **Timeline**  | Chronological session history, organized by date                                                               |

## Highlights

- Dual mode: structured Pomodoro and open-ended Flexible timers in one app.
- Tag-driven configuration: each activity context has its own presets instead of one global setting.
- Focus mode: Strict, Whitelist, and Loose modes on Android reduce distractions.
- Offline-first: the timer and data work locally, with no internet dependency.

## Known limitations (v1.0)

- Manual backfill of past sessions is not supported yet. See the [CHANGELOG](CHANGELOG.md).
- iOS support is secondary and best-effort compared with Android.

## Getting Started

For build and run instructions, see the [build guide](docs/HOW_TO.md).

## Privacy

Sessions, tags, and settings stay on the device. This release has no account system, no required network connection, and no telemetry. On Android, Usage Access is optional and needed only for Strict or Whitelist Focus mode. Local data is not encrypted at rest.

## License

Released under the [MIT](LICENSE) license. Copyright (c) 2026 Dafa Fawaz.
