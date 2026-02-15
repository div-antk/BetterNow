//
//  BetterEntry.swift
//  BetterNow
//
//  Created by Takuya Ando on 2026/02/15.
//

import Foundation

struct BetterEntry: Codable, Identifiable, Equatable, Sendable {
    /// 例: "2026-02-15"（日単位で1件にする想定）
    let id: String

    let createdAt: Date
    let action: String
    let choice: BetterChoice
    let caption: String

    init(
        id: String,
        createdAt: Date = .now,
        action: String,
        choice: BetterChoice,
        caption: String
    ) {
        self.id = id
        self.createdAt = createdAt
        self.action = action
        self.choice = choice
        self.caption = caption
    }
}
