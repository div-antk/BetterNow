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

    func save(action: String, choice: BetterChoice, caption: String, date: Date = .now) {
        let trimmedAction = action.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedCaption = caption.trimmingCharacters(in: .whitespacesAndNewlines)

        let id = DateFormatters.dayKey(date) // "YYYY-MM-DD"

        let entry = BetterEntry(
            id: id,
            createdAt: date,
            action: trimmedAction,
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
}
