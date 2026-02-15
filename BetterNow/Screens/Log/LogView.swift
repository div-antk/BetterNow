//
//  LogView.swift
//  BetterNow
//
//  Created by Takuya Ando on 2026/02/15.
//

import SwiftUI

/// Simple Log / Trend screen.
/// For now:
/// - Shows a placeholder chart area
/// - Lists recent entries (mocked)
/// Later:
/// - Replace mock data with SwiftData / persistence
struct LogView: View {
    @ObservedObject var store: EntryStore
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(store.entries) { entry in
                    HStack {
                        Text(entry.id) // dayKey
                            .font(.system(.body, design: .rounded))
                        
                        Spacer()
                        
                        Text(entry.choice.symbol)
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                            .foregroundStyle(color(for: entry.choice))
                    }
                }
                .onDelete { idxSet in
                    for idx in idxSet {
                        store.delete(id: store.entries[idx].id)
                    }
                }
            }
            .listStyle(.plain)
            .navigationTitle("log_title")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private func color(for choice: BetterChoice) -> Color {
        switch choice {
        case .up: .accentColor
        case .same: .secondary
        case .down: .red
        }
    }
}

#Preview {
    LogView(store: EntryStore())
}
