//
//  MainHeaderView.swift
//  BetterNow
//
//  Created by Takuya Ando on 2026/02/15.
//

import SwiftUI

struct MainHeaderView: View {
    @Binding var showLog: Bool

    var date: Date = .now

    var body: some View {
        HStack(spacing: 12) {
            appMarkPlaceholder

            Text(DateFormatters.headerDateCompact(date))                .font(.system(.title3, design: .rounded).weight(.black))
                .foregroundStyle(.primary)
                .lineLimit(1)

            Spacer(minLength: 0)

            Button {
                showLog = true
            } label: {
                Image(systemName: "chart.line.uptrend.xyaxis") // placeholder
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(.primary)
                    .frame(width: 36, height: 36)
                    .background(
                        Circle().fill(Color(.secondarySystemBackground))
                    )
            }
            .buttonStyle(.plain)
            .accessibilityLabel(Text("open_log_button"))
        }
        .frame(maxWidth: .infinity)
        .padding(.bottom, 6)
    }

    // MARK: - Subviews

    private var appMarkPlaceholder: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(Color(.secondarySystemBackground))
                .frame(width: 32, height: 32)

            Image(systemName: "arrow.up.right") // placeholder
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.secondary)
        }
        .accessibilityHidden(true)
    }
}

#Preview {
    MainHeaderView(showLog: .constant(false))
        .padding()
}
