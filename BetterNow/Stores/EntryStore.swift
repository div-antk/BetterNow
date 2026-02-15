//
//  EntryStore.swift
//  BetterNow
//
//  Created by Takuya Ando on 2026/02/15.
//

import Foundation
import Combine

@MainActor
final class EntryStore: ObservableObject {
    @Published private(set) var entries: [BetterEntry] = []

    private let defaults: UserDefaults
    private let storageKey = "better_entries_v1"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        load()
    }

    func save(choice: BetterChoice, caption: String, date: Date = .now) {
        let trimmedCaption = caption.trimmingCharacters(in: .whitespacesAndNewlines)
        let id = DateFormatters.dayKey(date) // "YYYY-MM-DD"

        let entry = BetterEntry(
            id: id,
            createdAt: date,
            choice: choice,
            caption: trimmedCaption
        )

        // 同じ日付は上書き
        if let idx = entries.firstIndex(where: { $0.id == id }) {
            entries[idx] = entry
        } else {
            entries.append(entry)
        }

        // 新しい順
        entries.sort { $0.id > $1.id }
        persist()
    }

    func delete(id: String) {
        entries.removeAll { $0.id == id }
        persist()
    }

    func load() {
        guard let data = defaults.data(forKey: storageKey) else {
            entries = []
            return
        }
        do {
            entries = try JSONDecoder().decode([BetterEntry].self, from: data)
            entries.sort { $0.id > $1.id }
        } catch {
            // 壊れてたら一旦空にする（必要ならリカバリ戦略入れる）
            entries = []
        }
    }

    private func persist() {
        do {
            let data = try JSONEncoder().encode(entries)
            defaults.set(data, forKey: storageKey)
        } catch {
            // ここは将来loggerに
            // print("persist error:", error)
        }
    }
    
    // 今日のEntryを取得
    func entry(for date: Date = .now) -> BetterEntry? {
        let id = DateFormatters.dayKey(date)
        return entries.first(where: { $0.id == id })
    }
    
    func seedTestData() {
        let cal = Calendar.autoupdatingCurrent
        let base = Date.now

        let samples: [(daysAgo: Int, choice: BetterChoice, caption: String)] = [
            (9, .up, "No energy"),
            (8, .up, "Busy day"),
            (7, .up, "Felt strong"),
            (6, .up, ""),
            (5, .up, "Good focus"),
            (4, .up, "Slept badly"),
            (3, .up, "Nice pace"),
            (2, .up, "Okay"),
            (1, .up, "Kept going"),
            (0, .up, "Today")
        ]

        for s in samples {
            if let date = cal.date(byAdding: .day, value: -s.daysAgo, to: base) {
                save(choice: s.choice, caption: s.caption, date: date)
            }
        }
    }

    func clearAll() {
        entries.removeAll()
        persist()
    }
}
