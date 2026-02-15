//
//  MainCaptionFieldView.swift
//  BetterNow
//
//  Created by Takuya Ando on 2026/02/15.
//

import SwiftUI

struct MainCaptionFieldView: View {
    @Binding var caption: String
    var onSubmit: () -> Void = {}

    @FocusState private var isFocused: Bool

    var body: some View {
        TextField("caption_placeholder", text: $caption)
            .textInputAutocapitalization(.sentences)
            .autocorrectionDisabled(false)
            .submitLabel(.done)
            .focused($isFocused)
            .onSubmit { onSubmit() }
            .padding(.vertical, 12)
            .padding(.horizontal, 14)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color(.secondarySystemBackground))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .strokeBorder(Color.primary.opacity(0.06), lineWidth: 1)
            ).padding(.top, 40)
    }
}

#Preview {
    MainCaptionFieldView(caption: .constant(""))
        .padding()
}
