//
//  SettingView.swift
//  BetterNow
//
//  Created by Takuya Ando on 2026/02/15.
//

import SwiftUI
import UserNotifications

struct SettingsView: View {
    @ObservedObject var store: EntryStore
    @StateObject private var reminderStore = ReminderSettingsStore()
    @Environment(\.dismiss) private var dismiss
    @State private var showsNotificationDeniedAlert = false

    var body: some View {
        NavigationStack {
            List {
                Section("reminder_section_title") {
                    Toggle("reminder_toggle_title", isOn: reminderEnabledBinding)

                    if reminderStore.isEnabled {
                        DatePicker(
                            "reminder_time_title",
                            selection: $reminderStore.reminderTime,
                            displayedComponents: .hourAndMinute
                        )
                        .datePickerStyle(.wheel)
                        .labelsHidden()
                    }
                }

                Section {
                    Button("Inject Test Data") {
                        store.seedTestData()
                    }

                    Button(role: .destructive) {
                        store.clearAll()
                    } label: {
                        Text("Clear All Data")
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .alert("reminder_denied_title", isPresented: $showsNotificationDeniedAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("reminder_denied_message")
            }
            .task {
                await ReminderNotificationManager.syncNotifications(
                    isEnabled: reminderStore.isEnabled,
                    reminderTime: reminderStore.reminderTime
                )
            }
            .onChange(of: reminderStore.reminderTime) { _, newValue in
                guard reminderStore.isEnabled else { return }

                Task {
                    await ReminderNotificationManager.syncNotifications(
                        isEnabled: reminderStore.isEnabled,
                        reminderTime: newValue
                    )
                }
            }
        }
    }

    private var reminderEnabledBinding: Binding<Bool> {
        Binding(
            get: { reminderStore.isEnabled },
            set: { newValue in
                Task {
                    if newValue {
                        let granted = await ReminderNotificationManager.requestAuthorization()
                        await MainActor.run {
                            guard granted else {
                                reminderStore.setEnabled(false)
                                showsNotificationDeniedAlert = true
                                return
                            }

                            reminderStore.setEnabled(true)
                        }

                        await ReminderNotificationManager.syncNotifications(
                            isEnabled: granted,
                            reminderTime: reminderStore.reminderTime
                        )
                    } else {
                        reminderStore.setEnabled(false)
                        await ReminderNotificationManager.syncNotifications(
                            isEnabled: false,
                            reminderTime: reminderStore.reminderTime
                        )
                    }
                }
            }
        )
    }
}
