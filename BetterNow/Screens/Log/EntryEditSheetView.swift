
//
//  EntryEditSheetView.swift
//  BetterNow
//
//  Created by Takuya Ando on 2026/03/05.
//

import SwiftUI
import UIKit

/// 編集ダイアログ（Bottom Sheet）
struct EntryEditSheetView: View {

    let entry: BetterEntry
    let onSave: (BetterChoice, String) -> Void
    /// dayKey優先で日付を作る（呼び出し側のヘルパーを注入）
    let dateForEntry: (_ id: String, _ createdAt: Date) -> Date

    @Environment(\.dismiss) private var dismiss

    @State private var choice: BetterChoice
    @State private var caption: String

    init(entry: BetterEntry,
         onSave: @escaping (BetterChoice, String) -> Void,
         dateForEntry: @escaping (_ id: String, _ createdAt: Date) -> Date) {
        self.entry = entry
        self.onSave = onSave
        self.dateForEntry = dateForEntry
        _choice = State(initialValue: entry.choice)
        _caption = State(initialValue: entry.caption)
    }

    /// 元の内容から変更があるか
    private var isDirty: Bool {
        let trimmed = caption.trimmingCharacters(in: .whitespacesAndNewlines)
        let original = entry.caption.trimmingCharacters(in: .whitespacesAndNewlines)
        return choice != entry.choice || trimmed != original
    }

    /// 編集対象の日付（表示用）
    private var displayDateText: String {
        let date = dateForEntry(entry.id, entry.createdAt)
        return DateFormatters.headerDateCompact(date)
    }

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 36) {
                HStack(spacing: 12) {
                    choiceButton(.skipped)
                    choiceButton(.up)
                    choiceButton(.same)
                    choiceButton(.down)
                }

                // ひとこと（任意）
                VStack(alignment: .leading, spacing: 12) {
                    Text("caption_prompt")
                        .font(.system(.footnote, design: .rounded).weight(.medium))
                        .foregroundStyle(.secondary)

                    TextField("caption_placeholder", text: $caption)
                        .textInputAutocapitalization(.sentences)
                        .autocorrectionDisabled(false)
                        .submitLabel(.done)
                        .padding(.vertical, 12)
                        .padding(.horizontal, 14)
                        .background(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(Color(.secondarySystemBackground))
                        )
                }

                Spacer(minLength: 0)
            }
            .padding(.horizontal, 24)
            .padding(.top, 16)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                // タイトル（センター表示）
                ToolbarItem(placement: .principal) {
                    Text(displayDateText)
                        .font(.system(.headline, design: .rounded))
                        .foregroundStyle(.primary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button("update_button") {
                        guard isDirty else { return }
                        onSave(choice, caption)
                        dismiss()
                    }
                    .font(.system(.callout, design: .rounded).weight(.semibold))
                    .disabled(!isDirty)
                    .foregroundStyle(isDirty ? Color.accentColor : Color.gray)
                }
            }
        }
        .presentationDetents([.medium])
    }

    private func choiceButton(_ c: BetterChoice) -> some View {
        let isSelected = (choice == c)

        return Button {
            withAnimation(.spring(response: 0.22, dampingFraction: 0.78)) {
                choice = c
            }
            UIImpactFeedbackGenerator(style: .soft).impactOccurred()
        } label: {
            Text(c.symbol)
                .font(.system(size: 28, weight: .semibold, design: .rounded))
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .foregroundStyle(foregroundColor(for: c, isSelected: isSelected))
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(backgroundColor(for: c, isSelected: isSelected))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .strokeBorder(borderColor(for: c, isSelected: isSelected), lineWidth: borderWidth(for: c, isSelected: isSelected))
            )
            .contentShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        }
        .buttonStyle(.plain)
        .accessibilityLabel(Text(LocalizedStringKey(c.a11yKey)))
        .accessibilityAddTraits(isSelected ? [.isSelected] : [])
    }

    private func backgroundColor(for choice: BetterChoice, isSelected: Bool) -> Color {
        switch (choice, isSelected) {
        case (.skipped, _):
            return .clear
        case (_, true):
            return .accentColor
        case (_, false):
            return Color(.secondarySystemBackground)
        }
    }

    private func borderColor(for choice: BetterChoice, isSelected: Bool) -> Color {
        switch (choice, isSelected) {
        case (.skipped, true):
            return Color(uiColor: .systemGray2)
        case (.skipped, false):
            return Color.secondary.opacity(0.18)
        case (_, true):
            return .accentColor
        case (_, false):
            return .clear
        }
    }

    private func borderWidth(for choice: BetterChoice, isSelected: Bool) -> CGFloat {
        switch (choice, isSelected) {
        case (.skipped, true):
            return 2
        case (.skipped, false):
            return 1
        case (_, true):
            return 0
        case (_, false):
            return 0
        }
    }

    private func foregroundColor(for choice: BetterChoice, isSelected: Bool) -> Color {
        switch (choice, isSelected) {
        case (.skipped, true):
            return Color(uiColor: .systemGray2)
        case (.skipped, false):
            return .primary
        case (_, true):
            return Color(.systemBackground)
        case (_, false):
            return .primary
        }
    }
}

#Preview {
    EntryEditSheetView(
        entry: BetterEntry(
            id: DateFormatters.dayKey(),
            createdAt: .now,
            choice: .same,
            caption: "A few words…"
        ),
        onSave: { _, _ in },
        dateForEntry: { _, createdAt in createdAt }
    )
    .padding()
}
