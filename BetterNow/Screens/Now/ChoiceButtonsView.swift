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
        VStack(alignment: .leading, spacing: 10) {
            Text("choice_prompt")
                .font(.system(.footnote, design: .rounded).weight(.medium))
                .foregroundStyle(.secondary)

            VStack(spacing: 12) {
                ForEach(BetterChoice.allCases) { c in
                    choiceButton(c)
                }
            }
        }
        .padding(.top, 4)
    }

    // MARK: - Subviews

    private func choiceButton(_ c: BetterChoice) -> some View {
        let isSelected = (choice == c)

        return Button {
            withAnimation(.easeInOut(duration: 0.15)) {
                choice = c
            }
            UIImpactFeedbackGenerator(style: .soft).impactOccurred()
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(isSelected ? Color.accentColor : Color(.secondarySystemBackground))

                Text(c.symbol)
                    .font(.system(size: 28, weight: .semibold, design: .rounded))
                    .foregroundStyle(isSelected ? .white : .primary)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 64)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(Text(LocalizedStringKey(c.a11yKey)))
        .accessibilityAddTraits(isSelected ? [.isSelected] : [])
    }
}

#Preview {
    ChoiceButtonsView(choice: .constant(.up))
        .padding()
}
