//
//  ContentView.swift
//  BetterNow
//
//  Created by Takuya Ando on 2026/02/14.
//

import SwiftUI
import UIKit

/// Better Now - Main Screen (SwiftUI)
/// - String Catalog (Localizable.xcstrings) 前提：Text("key") の形でキーを参照
/// - Light/Dark は systemBackground / primary などのシステム色に寄せて自動追従

struct BetterNowMainView: View {

    @State private var caption: String = ""
    @State private var choice: BetterChoice? = nil
    @StateObject private var store = EntryStore()
    
    @State private var showSettings = false
    @State private var showLog: Bool = false
    
    // すでにEntry済かどうかの判定
    @State private var existingEntry: BetterEntry? = nil

    // キーボード表示状態（背景タップで閉じる＆誤タップ防止用）
    @State private var isKeyboardVisible: Bool = false

    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()

            VStack(spacing: 16) {
                MainHeaderView(showLog: $showLog, showSettings: $showSettings)
                Spacer()
                ChoiceButtonsView(choice: $choice)
                MainCaptionFieldView(caption: $caption)
                MainFooterButtonsView(
                    primaryTitle: primaryButtonTitleKey,
                    canSave: canSave,
                    onClear: { clearInputs() },
                    onSave: { saveEntry() }
                )
                Spacer(minLength: 0)
            }
            .padding(.horizontal, 24)
            .padding(.top, 16)
            .sheet(isPresented: $showLog) {
                LogView(store: store)
            }
            .sheet(isPresented: $showSettings) { SettingsView(store: store) }
            .onAppear {
                loadTodayIfExists()
            }

            // キーボード表示中は画面全体を透明レイヤーで覆う
            // → 背景タップでキーボードを閉じる & 下のボタン誤タップを防ぐ
            if isKeyboardVisible {
                Color.clear
                    .contentShape(Rectangle())
                    .ignoresSafeArea()
                    .onTapGesture {
                        dismissKeyboard()
                    }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { _ in
            isKeyboardVisible = true
        }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in
            isKeyboardVisible = false
        }
    }

    // MARK: - Logic

    private var isUpdateMode: Bool {
        existingEntry != nil
    }

    private var hasChanges: Bool {
        guard let existingEntry else {
            // 新規保存モードは「choiceがあれば保存可能」でOK
            return true
        }

        // 変更判定（トリムして比較）
        let captionNow = caption.trimmingCharacters(in: .whitespacesAndNewlines)
        let captionChanged = captionNow != existingEntry.caption
        let choiceChanged = choice != existingEntry.choice

        // caption or choiceで判定
        return captionChanged || choiceChanged
    }

    private var primaryButtonTitleKey: LocalizedStringKey {
        isUpdateMode ? "update_button" : "save_button"
    }

    private var canSave: Bool {
        // choice 必須
        guard choice != nil else { return false }

        // Updateのときは変更がないならdisabled
        if isUpdateMode {
            return hasChanges
        } else {
            return true
        }
    }

    private func saveEntry() {
        guard let choice else { return }

        store.save(
            choice: choice,
            caption: caption
        )
        // 保存後、今日の基準を更新して「変更なし」を正しく判定できるようにする
        existingEntry = store.entry(for: .now)

        UIImpactFeedbackGenerator(style: .light).impactOccurred()

        // 保存後ログへ遷移
        showLog = true
    }

    private func clearInputs() {
        caption = ""
        choice = nil
    }
    
    // 既に今日の入力があれば、UIに反映
    private func loadTodayIfExists() {
        guard let entry = store.entry(for: .now) else {
            existingEntry = nil
            return
        }
        existingEntry = entry
        caption = entry.caption
        choice = entry.choice
    }

    /// キーボードを閉じる（フォーカス中の入力を終了）
    private func dismissKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                        to: nil,
                                        from: nil,
                                        for: nil)
    }
}

#Preview {
    BetterNowMainView()
}
