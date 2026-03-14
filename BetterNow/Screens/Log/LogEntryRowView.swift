//
//  LogEntryRowView.swift
//  BetterNow
//
//  Created by Takuya Ando on 2026/02/15.
//

import SwiftUI

/// ログ一覧の1行表示
/// - 上段: 日付
/// - 下段: Caption（空なら非表示）
/// - 右側: BetterChoice のシンボル
struct LogEntryRowView: View {

    let entry: BetterEntry
//    var onDelete: (() -> Void)? = nil
    var onTap: (() -> Void)? = nil
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {

            HStack(alignment: .firstTextBaseline) {

                VStack(alignment: .leading, spacing: 4) {

                    Text(formattedDate)
                        .font(.system(.body, design: .rounded).weight(.medium))
                        .foregroundStyle(.primary)

                    if !entry.caption.isEmpty {
                        Text(entry.caption)
                            .font(.system(.callout, design: .rounded))
                            .foregroundStyle(.secondary)
                            .lineLimit(2)
                    }
                }

                Spacer(minLength: 0)

                Text(entry.choice.symbol)
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundStyle(color(for: entry.choice))
                    .padding(.leading, 8)
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(Color(.secondarySystemBackground))
        )
        .contentShape(Rectangle())
        .onTapGesture {
            onTap?()
        }
        // FIXME: 削除処理は本当に必要か検討
//        .contextMenu {
//            if let onDelete {
//                Button(role: .destructive) {
//                    onDelete()
//                } label: {
//                    Label("delete_entry_button", systemImage: "trash")
//                }
//            }
//        }
    }

    private var formattedDate: String {
        let date = DateFormatters.dateFromDayKey(entry.id) ?? entry.createdAt
        return DateFormatters.headerDateCompact(date)
    }

    private func color(for choice: BetterChoice) -> Color {
        switch choice {
        case .skipped:
            return Color.secondary.opacity(0.8)
        case .up:
            return .accentColor
        case .same:
            return .secondary
        case .down:
            return .secondary
        }
    }
}

#Preview {
    LogEntryRowView(
        entry: BetterEntry(
            id: DateFormatters.dayKey(),
            createdAt: .now,
            choice: .up,
            caption: "Good focus today"
        )
    )
    .padding()
}
