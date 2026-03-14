//
//  ReminderSettingsStore.swift
//  BetterNow
//
//  Created by Codex on 2026/03/15.
//

import Foundation
import Combine

@MainActor
final class ReminderSettingsStore: ObservableObject {
    @Published var isEnabled: Bool {
        didSet {
            defaults.set(isEnabled, forKey: isEnabledKey)
        }
    }

    @Published var reminderTime: Date {
        didSet {
            defaults.set(reminderTime, forKey: reminderTimeKey)
        }
    }

    private let defaults: UserDefaults
    private let isEnabledKey = "reminder_enabled_v1"
    private let reminderTimeKey = "reminder_time_v1"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        self.isEnabled = defaults.bool(forKey: isEnabledKey)

        if let storedDate = defaults.object(forKey: reminderTimeKey) as? Date {
            self.reminderTime = storedDate
        } else {
            self.reminderTime = Self.defaultReminderTime()
        }
    }

    func setEnabled(_ enabled: Bool) {
        isEnabled = enabled
    }

    private static func defaultReminderTime() -> Date {
        let cal = Calendar.autoupdatingCurrent
        let now = Date()
        return cal.date(
            bySettingHour: 20,
            minute: 0,
            second: 0,
            of: now
        ) ?? now
    }
}
