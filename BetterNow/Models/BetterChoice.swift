//
//  BetterChoice.swift
//  BetterNow
//
//  Created by Takuya Ando on 2026/02/15.
//

import Foundation

enum BetterChoice: Int, CaseIterable, Identifiable, Codable, Sendable {
    case up = 1
    case same = 0
    case down = -1
    case skipped = 2

    var id: Int { rawValue }

    var deltaValue: Int {
        switch self {
        case .up:
            return 1
        case .same, .skipped:
            return 0
        case .down:
            return -1
        }
    }

    /// Symbol displayed in the UI.
    var symbol: String {
        switch self {
        case .skipped: return "○"
        case .up: return "↑"
        case .same: return "→"
        case .down: return "↓"
        }
    }

    /// Accessibility label key (String Catalog key).
    var a11yKey: String {
        switch self {
        case .skipped: return "better_choice_skip_a11y"
        case .up: return "better_choice_up"
        case .same: return "better_choice_same"
        case .down: return "better_choice_down"
        }
    }
}
