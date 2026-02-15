//
//  MainFooterButtonsView.swift
//  BetterNow
//
//  Created by Takuya Ando on 2026/02/15.
//

import SwiftUI

struct MainFooterButtonsView: View {
    var primaryTitle: LocalizedStringKey
    var canSave: Bool
    var onClear: () -> Void
    var onSave: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            // Clear (left) - no background, but keep a solid tappable area
            Button(action: onClear) {
                Text("clear_button")
                    .font(.system(.callout, design: .rounded).weight(.medium))
                    .frame(width: 92, height: 48)
                    .foregroundStyle(.secondary)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            // Save (right)
            Button(action: onSave) {
                Text(primaryTitle)
                    .font(.system(.callout, design: .rounded).weight(.semibold))
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(canSave ? Color.accentColor : Color.accentColor.opacity(0.15))
                    )
                    .foregroundStyle(canSave ? Color(.systemBackground) : .secondary)
            }
            .buttonStyle(.plain)
            .disabled(!canSave)
        }
        .padding(.top, 2)
    }
}

#Preview {
    VStack(spacing: 20) {
        MainFooterButtonsView(primaryTitle: "test", canSave: false, onClear: {}, onSave: {})
    }
    .padding()
}
