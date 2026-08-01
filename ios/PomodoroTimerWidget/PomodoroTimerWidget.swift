//
//  PomodoroTimerWidget.swift
//  PomodoroTimerWidget — Live Activity for running timer (iOS 16.1+)
//

import ActivityKit
import SwiftUI
import WidgetKit

@main
struct PomodoroTimerWidgets: WidgetBundle {
  var body: some Widget {
    if #available(iOS 16.1, *) {
      PomodoroRunningTimerLiveActivity()
    }
  }
}

/// MUST be named exactly `LiveActivitiesAppAttributes` for live_activities plugin.
struct LiveActivitiesAppAttributes: ActivityAttributes, Identifiable {
  public typealias LiveDeliveryData = ContentState

  public struct ContentState: Codable, Hashable {}

  var id = UUID()
}

extension LiveActivitiesAppAttributes {
  func prefixedKey(_ key: String) -> String {
    "\(id)_\(key)"
  }
}

let sharedDefault = UserDefaults(suiteName: "group.com.dpzstudio.pomodoroapp")!

@available(iOSApplicationExtension 16.1, *)
struct PomodoroRunningTimerLiveActivity: Widget {
  var body: some WidgetConfiguration {
    ActivityConfiguration(for: LiveActivitiesAppAttributes.self) { context in
      RunningTimerLockScreenView(attributes: context.attributes)
    } dynamicIsland: { context in
      let title = sharedDefault.string(
        forKey: context.attributes.prefixedKey("title")
      ) ?? "Timer"
      return DynamicIsland {
        DynamicIslandExpandedRegion(.leading) {
          Text(title)
            .font(.headline)
            .fontWeight(.semibold)
        }
        DynamicIslandExpandedRegion(.trailing) {
          RunningTimerText(attributes: context.attributes)
            .monospacedDigit()
            .font(.title2)
            .fontWeight(.bold)
        }
        DynamicIslandExpandedRegion(.bottom) {
          Text("Pomodoro")
            .font(.caption)
            .foregroundStyle(.secondary)
        }
      } compactLeading: {
        Text(String(title.prefix(1)))
          .fontWeight(.bold)
      } compactTrailing: {
        RunningTimerText(attributes: context.attributes)
          .monospacedDigit()
          .font(.caption)
          .frame(minWidth: 40)
      } minimal: {
        RunningTimerText(attributes: context.attributes)
          .monospacedDigit()
          .font(.caption2)
      }
    }
  }
}

@available(iOSApplicationExtension 16.1, *)
private struct RunningTimerLockScreenView: View {
  let attributes: LiveActivitiesAppAttributes

  var body: some View {
    let title = sharedDefault.string(forKey: attributes.prefixedKey("title")) ?? "Timer"
    HStack(spacing: 16) {
      VStack(alignment: .leading, spacing: 4) {
        Text(title)
          .font(.headline)
          .fontWeight(.semibold)
        Text("Pomodoro")
          .font(.caption)
          .foregroundStyle(.secondary)
      }
      Spacer()
      RunningTimerText(attributes: attributes)
        .monospacedDigit()
        .font(.system(size: 36, weight: .bold, design: .rounded))
    }
    .padding(20)
  }
}

@available(iOSApplicationExtension 16.1, *)
private struct RunningTimerText: View {
  let attributes: LiveActivitiesAppAttributes

  var body: some View {
    let paused = sharedDefault.integer(forKey: attributes.prefixedKey("paused")) != 0
    let countDown = sharedDefault.integer(forKey: attributes.prefixedKey("countDown")) != 0
    let anchorMs = sharedDefault.double(forKey: attributes.prefixedKey("anchorUtcMs"))
    let timerLabel =
      sharedDefault.string(forKey: attributes.prefixedKey("timerLabel")) ?? "--:--"

    if paused || anchorMs <= 0 {
      Text(timerLabel)
    } else if countDown {
      let end = Date(timeIntervalSince1970: anchorMs / 1000)
      let start = Date()
      if end > start {
        Text(timerInterval: start...end, countsDown: true)
      } else {
        Text("00:00")
      }
    } else {
      let start = Date(timeIntervalSince1970: anchorMs / 1000)
      Text(timerInterval: start...Date.distantFuture, countsDown: false)
    }
  }
}
