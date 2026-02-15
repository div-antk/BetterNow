//
//  LogView.swift
//  BetterNow
//
//  Created by Takuya Ando on 2026/02/15.
//

import SwiftUI

/// Log / Trend screen
/// - Chart on top
/// - Entries list below
struct LogView: View {
    
    @ObservedObject var store: EntryStore
    // 設定（テストデータ投入用）
    @State private var showSettings = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    LogChartView(entries: store.entries)
                    VStack(spacing: 8) {
                        ForEach(sortedEntries) { entry in
                            LogEntryRowView(
                                entry: entry,
                                onDelete: { store.delete(id: entry.id) }
                            )
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 16)
            }
            .navigationTitle("log_title")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showSettings = true
                    } label: {
                        Image(systemName: "gearshape")
                    }
                }
            }
            .sheet(isPresented: $showSettings) {
                SettingsView(store: store)
            }
        }
    }

    // MARK: - Derived data

    private var sortedEntries: [BetterEntry] {
        store.entries.sorted { $0.id > $1.id } // dayKey desc
    }
}

#Preview {
    let store = EntryStore()
    // Example mock: 7 days of ups (should trend upward)
    let cal = Calendar.autoupdatingCurrent
    for i in (0...6).reversed() {
        let d = cal.date(byAdding: .day, value: -i, to: .now) ?? .now
        store.save(choice: .up, caption: "up", date: d)
    }
    return LogView(store: store)
}
