//
//  LogView.swift
//  BetterNow
//
//  Created by Takuya Ando on 2026/02/15.
//

import SwiftUI
import UIKit

/// Log / Trend screen
/// - Chart on top
/// - Entries list below
struct LogView: View {
    
    @ObservedObject var store: EntryStore
    // 設定（テストデータ投入用）
    @State private var showSettings = false
    // 編集対象（タップでセット → sheet を出す）
    @State private var editingEntry: BetterEntry? = nil
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    LogChartView(entries: store.entries)
                    VStack(spacing: 8) {
                        ForEach(sortedEntries) { entry in
                            LogEntryRowView(
                                entry: entry,
                                onTap: { editingEntry = entry },
//                                onDelete: { store.delete(id: entry.id) }
                            )
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 16)
            }
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
            .sheet(item: $editingEntry) { entry in
                EntryEditSheetView(
                    entry: entry,
                    onSave: { newChoice, newCaption in
                        // dayKey（YYYY-MM-DD）を優先して、その日の0:00に寄せて保存
                        let date = DateFormatters.dateFromDayKey(entry.id) ?? entry.createdAt
                        store.save(choice: newChoice, caption: newCaption, date: date)

                        // sheet(item:) なので、nil にすると閉じる（dismiss() も効くけど保険）
                        editingEntry = nil
                    },
                    dateForEntry: { id, createdAt in
                        DateFormatters.dateFromDayKey(id) ?? createdAt
                    }
                )
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
