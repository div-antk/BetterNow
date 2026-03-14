//
//  BetterNowApp.swift
//  BetterNow
//
//  Created by Takuya Ando on 2026/02/14.
//

import SwiftUI

@main
struct BetterNowApp: App {
    @State private var showsSplash = true

    var body: some Scene {
        WindowGroup {
            ZStack {
                BetterNowMainView()
                    .opacity(showsSplash ? 0 : 1)

                if showsSplash {
                    SplashView()
                        .transition(.opacity)
                }
            }
            .task {
                guard showsSplash else { return }
                try? await Task.sleep(for: .milliseconds(1400))
                withAnimation(.easeInOut(duration: 0.35)) {
                    showsSplash = false
                }
            }
        }
    }
}
