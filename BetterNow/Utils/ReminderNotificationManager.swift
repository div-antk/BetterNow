//
//  ReminderNotificationManager.swift
//  BetterNow
//
//  Created by Codex on 2026/03/15.
//

import Foundation
import UserNotifications

enum ReminderNotificationManager {
    static let requestIdentifier = "daily-reminder"

    static func requestAuthorization() async -> Bool {
        let center = UNUserNotificationCenter.current()

        do {
            return try await center.requestAuthorization(options: [.alert, .sound, .badge])
        } catch {
            return false
        }
    }

    static func syncNotifications(isEnabled: Bool, reminderTime: Date) async {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [requestIdentifier])

        guard isEnabled else { return }

        let content = UNMutableNotificationContent()
        content.title = NSLocalizedString("reminder_notification_title", comment: "")
        content.body = NSLocalizedString("reminder_notification_body", comment: "")
        content.sound = .default

        let cal = Calendar.autoupdatingCurrent
        let components = cal.dateComponents([.hour, .minute], from: reminderTime)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let request = UNNotificationRequest(
            identifier: requestIdentifier,
            content: content,
            trigger: trigger
        )

        do {
            try await center.add(request)
        } catch {
            return
        }
    }
}
