//
//  ChoiceButtonsView.swift
//  BetterNow
//
//  Created by Takuya Ando on 2026/02/15.
//

import SwiftUI

struct ChoiceButtonsView: View {
    @Binding var choice: BetterChoice?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("choice_prompt")
                .font(.system(.footnote, design: .rounded).weight(.medium))
                .foregroundStyle(.secondary)
            VStack(spacing: 12) {
                ForEach(BetterChoice.allCases) { c in
                    choiceButton(c)
                }
            }
        }
    }

    // MARK: - Subviews

    private func choiceButton(_ c: BetterChoice) -> some View {
        let isSelected = (choice == c)
        let isSkipped = c == .skipped

        return Button {
            withAnimation(.easeInOut(duration: 0.15)) {
                choice = c
            }
            UIImpactFeedbackGenerator(style: .soft).impactOccurred()
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(backgroundColor(for: c, isSelected: isSelected))

                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .strokeBorder(borderColor(for: c, isSelected: isSelected), lineWidth: borderWidth(for: c, isSelected: isSelected))

                Text(c.symbol)
                    .font(.system(size: 28, weight: .semibold, design: .rounded))
                    .foregroundStyle(foregroundColor(for: c, isSelected: isSelected))
            }
            .frame(maxWidth: .infinity)
            .frame(height: 64)
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
            return .white
        case (_, false):
            return .primary
        }
    }
}

#Preview {
    ChoiceButtonsView(choice: .constant(.up))
        .padding()
}
