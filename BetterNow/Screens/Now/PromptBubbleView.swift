//
//  PromptBubbleView.swift
//  BetterNow
//
//  Created by Takuya Ando on 2026/03/14.
//

import SwiftUI

struct PromptBubbleView: View {
    var body: some View {
        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.accentColor.opacity(0.32))

            Text("choice_prompt")
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundStyle(.primary.opacity(0.86))
                .padding(.horizontal, 24)
                .padding(.vertical, 32)
        }
        .fixedSize(horizontal: false, vertical: true)
        .accessibilityAddTraits(.isHeader)
    }
}

#Preview {
    PromptBubbleView()
        .padding()
}
