//
//  MainHeaderView.swift
//  BetterNow
//
//  Created by Takuya Ando on 2026/02/15.
//

import SwiftUI

struct MainHeaderView: View {
    @Binding var showLog: Bool
    @Binding var showSettings: Bool

    var date: Date = .now

    var body: some View {
        HStack(spacing: 12) {
            Button {
                showSettings = true
            } label: {
                settingsIcon
            }
            .buttonStyle(.plain)
            .accessibilityLabel(Text("open_settings_button"))

            Text(DateFormatters.headerDateCompact(date))                .font(.system(.title3, design: .rounded).weight(.black))
                .foregroundStyle(.primary)
                .lineLimit(1)

            Spacer(minLength: 0)

            Button {
                showLog = true
            } label: {
                Image(systemName: "chart.line.uptrend.xyaxis") // placeholder
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.primary)
                    .frame(width: 36, height: 36)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(Text("open_log_button"))
        }
        .frame(maxWidth: .infinity)
        .padding(.bottom, 6)
    }

    // MARK: - Subviews

    private var settingsIcon: some View {
        Image(systemName: "gearshape")
            .font(.system(size: 16, weight: .semibold))
            .foregroundStyle(.secondary)
    }
}

#Preview {
    MainHeaderView(showLog: .constant(false), showSettings: .constant(false))
        .padding()
}
