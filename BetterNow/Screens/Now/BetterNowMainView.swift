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
    // すでにEntry済かどうかの判定
    @State private var existingEntry: BetterEntry? = nil
    
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
                    primaryTitle: LocalizedStringKey(primaryButtonTitleKey),
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
            .onAppear {
                applyExistingEntryIfNeeded()
            }
            .onAppear {
                loadTodayIfExists()
            }
        }
        .overlay(alignment: .top) { toast }
    }

    // MARK: - UI

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

    private var isUpdateMode: Bool {
        existingEntry != nil
    }

    private var hasChanges: Bool {
        guard let existingEntry else {
            // 新規保存モードは「choiceがあれば保存可能」でOK
            return true
        }

        // 変更判定（トリムして比較）
        let actionNow = todayAction.trimmingCharacters(in: .whitespacesAndNewlines)
        let captionNow = caption.trimmingCharacters(in: .whitespacesAndNewlines)
        let captionChanged = captionNow != existingEntry.caption
        let choiceChanged = choice != existingEntry.choice

        // 指定どおりなら「caption or choice」だけで判定したいのでこう：
        return captionChanged || choiceChanged
    }

    private var primaryButtonTitleKey: String {
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

        // TODO: SwiftData / CoreData / UserDefaults に差し替え
        store.save(
            action: todayAction,
            choice: choice,
            caption: caption
        )
        // 保存後、今日の基準を更新して「変更なし」を正しく判定できるようにする
        existingEntry = store.entry(for: .now)

        UIImpactFeedbackGenerator(style: .light).impactOccurred()

        // 保存後ログへ遷移
        showLog = true
    }

    private func clearInputs(keepKeyboard: Bool = false) {
        todayAction = ""
        caption = ""
        choice = nil

        focus = keepKeyboard ? .action : nil
    }
    
    private func applyExistingEntryIfNeeded() {
        guard let entry = store.entry(for: .now) else { return }

        // 既に今日の入力があれば、UIに反映
        todayAction = entry.action
        caption = entry.caption
        choice = entry.choice
    }
    private func loadTodayIfExists() {
        guard let entry = store.entry(for: .now) else {
            existingEntry = nil
            return
        }
        existingEntry = entry
        todayAction = entry.action
        caption = entry.caption
        choice = entry.choice
    }
}

#Preview {
    BetterNowMainView()
}
