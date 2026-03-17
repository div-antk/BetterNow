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

// TODO: Mainに昨日のエントリを載せる
// TODO: Splash画面作成
// TODO: AppleWatch対応
// TODO: Widget対応

struct BetterNowMainView: View {
    private enum ScrollTarget {
        static let captionField = "caption-field"
    }

    @State private var caption: String = ""
    @State private var choice: BetterChoice? = nil
    @StateObject private var store = EntryStore()
    
    @State private var showSettings = false
    @State private var showLog: Bool = false
    
    // すでにEntry済かどうかの判定
    @State private var existingEntry: BetterEntry? = nil

    // キーボード表示状態（背景タップで閉じる＆誤タップ防止用）
    @State private var isKeyboardVisible: Bool = false
    @State private var keyboardHeight: CGFloat = 0

    var body: some View {
        GeometryReader { proxy in
            ScrollViewReader { scrollProxy in
                ZStack {
                    Color(.systemBackground).ignoresSafeArea()

                    if isKeyboardVisible {
                        Color.clear
                            .contentShape(Rectangle())
                            .ignoresSafeArea()
                            .onTapGesture {
                                dismissKeyboard()
                            }
                    }

                    VStack(spacing: 0) {
                        MainHeaderView(showLog: $showLog, showSettings: $showSettings)
                            .padding(.horizontal, 24)
                            .padding(.top, 8)
                            .background {
                                ZStack(alignment: .bottom) {
                                    Color(.systemBackground)

                                    LinearGradient(
                                        colors: [
                                            Color(.systemBackground),
                                            Color(.systemBackground).opacity(0.92),
                                            Color(.systemBackground).opacity(0.0)
                                        ],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                    .frame(height: 24)
                                    .offset(y: 24)
                                }
                            }
                            .zIndex(1)

                        ScrollView(showsIndicators: false) {
                            VStack(spacing: 16) {
                                ChoiceButtonsView(choice: $choice)
                                MainCaptionFieldView(caption: $caption)
                                    .id(ScrollTarget.captionField)
                                MainFooterButtonsView(
                                    primaryTitle: primaryButtonTitleKey,
                                    canSave: canSave,
                                    onClear: { clearInputs() },
                                    onSave: { saveEntry() }
                                )
                                Spacer(minLength: isKeyboardVisible ? 12 : 0)
                            }
                            .frame(
                                minHeight: max(proxy.size.height - keyboardInset(for: proxy) - 88, 0),
                                alignment: .top
                            )
                            .padding(.horizontal, 24)
                            .padding(.top, 36)
                            .padding(.bottom, keyboardInset(for: proxy) + 16)
                        }
                        .scrollDismissesKeyboard(.interactively)
                    }
                    .sheet(isPresented: $showLog, onDismiss: {
                        // Log画面で編集された内容をMain画面に反映する
                        loadTodayIfExists()
                    }) {
                        LogView(store: store)
                    }
                    .sheet(isPresented: $showSettings) { SettingsView(store: store) }
                    .onAppear {
                        loadTodayIfExists()
                    }
                    .onChange(of: isKeyboardVisible) { _, isVisible in
                        guard isVisible else { return }

                        withAnimation(.easeInOut(duration: 0.25)) {
                            scrollProxy.scrollTo(ScrollTarget.captionField, anchor: .center)
                        }
                    }
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { notification in
            keyboardHeight = keyboardHeight(from: notification)
            isKeyboardVisible = true
        }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in
            isKeyboardVisible = false
            keyboardHeight = 0
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

    private func keyboardHeight(from notification: Notification) -> CGFloat {
        guard
            let frameValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue
        else {
            return 0
        }

        return frameValue.cgRectValue.height
    }

    private func keyboardInset(for proxy: GeometryProxy) -> CGFloat {
        max(0, keyboardHeight - proxy.safeAreaInsets.bottom)
    }
}

#Preview {
    BetterNowMainView()
}
