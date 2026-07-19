# Privacy Policy — Pomodoro App

**Last updated:** 2026-07-18  
**Product:** Pomodoro (offline-first focus timer)  
**Publisher:** DPZ Studio (`com.dpzstudio.pomodoro_app`)

This document describes what data the app processes on device. It is intended for end users and for Google Play **Data safety** declarations.

## Summary

| Topic                | Practice                                             |
| -------------------- | ---------------------------------------------------- |
| Accounts / login     | None                                                 |
| Internet / analytics | No required network; no third-party telemetry in MVP |
| Ads                  | None                                                 |
| Cloud sync           | None in MVP                                          |
| Data location        | On-device only (SQLite + app preferences)            |

## Data stored on the device

The app stores locally:

- Timer **sessions** and **segments** (timestamps, durations, status, mode)
- **Tags** (name, color, timer presets)
- **Settings** (theme, language, alert tones, focus mode, whitelist package names)
- Transient **active timer** recovery state

This data is **not encrypted at rest** in MVP (acceptable for non-account productivity data). Android **Auto Backup / cloud backup is disabled** (`allowBackup=false` + extraction/backup exclude rules) so sessions and whitelist entries are not copied to Google cloud backup or device-transfer archives by default.

Uninstalling the app removes local data.

## Sensitive / restricted permissions

### Notifications (`POST_NOTIFICATIONS`)

Used for segment-end alerts, focus failure alerts, Flexible reminders, and the background running-timer notification. Permission is requested **just-in-time** (when alerts are first needed), not on cold start.

### Exact alarms (`SCHEDULE_EXACT_ALARM`)

Used so segment-end notifications can fire near the planned wall-clock time while the app is backgrounded. If the system denies exact alarms, the app falls back to inexact scheduling.

### Usage access (`PACKAGE_USAGE_STATS`) — optional Focus modes

**Only** when the user enables **Strict** or **Whitelist** Focus mode:

- The app may request **Usage Access** so it can detect when another app is in the foreground during a focus session (distraction policy).
- Access is granted by the user in system Settings; the app opens that screen and does not silently grant itself access.
- Usage signals are processed **on device** to decide focus violations. They are **not** uploaded.

If Focus mode stays **Loose**, Usage Access is not required for core timer use.

### Installed apps (Whitelist picker)

When configuring a Focus whitelist, the app lists **launchable** apps visible to it (via the standard launcher intent query — not a blanket “query all packages” Play-restricted permission). Package names the user selects are stored locally in settings. The list is not shared off-device.

## What we do not collect

- Name, email, phone, or payment data
- Precise location
- Contacts or photos
- Crash/analytics SDKs that send usage off-device (MVP)

## Children

The app is a general productivity tool and is not directed at children under 13. Do not use it to process children’s personal information.

## Contact

For privacy questions about this app, contact the publisher via the store listing or project repository associated with DPZ Studio / `com.dpzstudio.pomodoro_app`.

## Changes

Material changes to this policy will update the **Last updated** date above and, when required, the Play Console Data safety form.
