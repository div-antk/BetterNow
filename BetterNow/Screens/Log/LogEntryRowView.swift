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
    var onDelete: (() -> Void)? = nil

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
        .contextMenu {
            // FIXME: 長押しで削除できる
            if let onDelete {
                Button(role: .destructive) {
                    onDelete()
                } label: {
                    Label("delete_entry_button", systemImage: "trash")
                }
            }
        }
    }

    // MARK: - Formatting

    // entry.id (YYYY-MM-DD) を優先して日付に変換
    // 失敗時は createdAt を使用
    private var formattedDate: String {
        let date = dateFromDayKey(entry.id) ?? entry.createdAt
        return DateFormatters.headerDateCompact(date)
    }

    // "YYYY-MM-DD" を Date に変換（その日の 0:00）
    private func dateFromDayKey(_ dayKey: String,
                                timeZone: TimeZone = .autoupdatingCurrent) -> Date? {

        let parts = dayKey.split(separator: "-")
        guard parts.count == 3,
              let y = Int(parts[0]),
              let m = Int(parts[1]),
              let d = Int(parts[2]) else { return nil }

        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = timeZone

        var comps = DateComponents()
        comps.year = y
        comps.month = m
        comps.day = d
        comps.hour = 0
        comps.minute = 0
        comps.second = 0

        return cal.date(from: comps)
    }

    private func color(for choice: BetterChoice) -> Color {
        switch choice {
        case .up:
            return .accentColor
        case .same:
            return .secondary
        case .down:
            return .red
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
