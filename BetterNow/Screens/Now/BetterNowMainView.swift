//
//  ContentView.swift
//  BetterNow
//
//  Created by Takuya Ando on 2026/02/14.
//

import SwiftUI

/// Better Now - Main Screen (SwiftUI)
/// - String Catalog (Localizable.xcstrings) 前提：Text("key") の形でキーを参照
/// - Light/Dark は systemBackground / primary などのシステム色に寄せて自動追従

struct BetterNowMainView: View {

    @State private var todayAction: String = ""
    @State private var caption: String = ""
    @State private var choice: BetterChoice? = nil
    @StateObject private var store = EntryStore()
    
    @State private var showSavedToast: Bool = false
    @State private var showLog: Bool = false

    @FocusState private var focus: FocusField?

    enum FocusField { case action, caption }

    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()

            VStack(spacing: 16) {
                MainHeaderView(showLog: $showLog)
                Spacer()
                ChoiceButtonsView(choice: $choice)
                MainCaptionFieldView(caption: $caption)
                MainFooterButtonsView(
                    canSave: canSave,
                    onClear: { clearInputs() },
                    onSave: { saveEntry() }
                )
                Spacer(minLength: 0)
            }
            .padding(.horizontal, 24)
            .padding(.top, 16)
            .toolbar { keyboardToolbar }
            .sheet(isPresented: $showLog) {
                LogView(store: store)
            }
        }
        .overlay(alignment: .top) { toast }
    }

    // MARK: - UI

    /// 仮のログ画面
    private struct PlaceholderLogView: View {
        var body: some View {
            NavigationStack {
                Text("log_placeholder") // String Catalogに追加しておくと便利
                    .foregroundStyle(.secondary)
                    .navigationTitle("log_title") // e.g. "Log"
                    .navigationBarTitleDisplayMode(.inline)
            }
        }
    }

    @ToolbarContentBuilder
    private var keyboardToolbar: some ToolbarContent {
        ToolbarItemGroup(placement: .keyboard) {
            Spacer()
            Button("done_button") { // "Done"
                focus = nil
            }
        }
    }

    private var toast: some View {
        Group {
            if showSavedToast {
                Text("saved_toast") // "Saved."
                    .font(.system(.footnote, design: .rounded).weight(.medium))
                    .padding(.vertical, 10)
                    .padding(.horizontal, 14)
                    .background(Capsule().fill(Color.primary.opacity(0.10)))
                    .foregroundStyle(.primary)
                    .padding(.top, 10)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .animation(.easeOut(duration: 0.18), value: showSavedToast)
    }

    // MARK: - Logic

    private var canSave: Bool {
        // choice だけ必須にする
        choice != nil
    }

    private func saveEntry() {
        guard let choice else { return }

        // TODO: SwiftData / CoreData / UserDefaults に差し替え
        store.save(
            action: todayAction,
            choice: choice,
            caption: caption
        )
        UIImpactFeedbackGenerator(style: .light).impactOccurred()

        withAnimation { showSavedToast = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            withAnimation { showSavedToast = false }
        }

        clearInputs(keepKeyboard: true)
    }

    private func clearInputs(keepKeyboard: Bool = false) {
        todayAction = ""
        caption = ""
        choice = nil

        focus = keepKeyboard ? .action : nil
    }
}

#Preview {
    BetterNowMainView()
}
