//
//  SplashView.swift
//  BetterNow
//
//  Created by Takuya Ando on 2026/03/14.
//

import SwiftUI

struct SplashView: View {
    @Environment(\.colorScheme) private var colorScheme
    @State private var isVisible = false

    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()

            VStack {
                appLogoImage
                    .frame(width: 160, height: 160)

                Text("Better Now")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundStyle(.primary)
            }
            .scaleEffect(isVisible ? 1 : 0.94)
            .opacity(isVisible ? 1 : 0)
        }
        .task {
            withAnimation(.easeOut(duration: 0.45)) {
                isVisible = true
            }
        }
    }

    private var appLogoImage: some View {
        Image(colorScheme == .dark ? "AppLogoDark" : "AppLogoLight")
            .resizable()
            .scaledToFit()
    }
}

#Preview {
    SplashView()
}
