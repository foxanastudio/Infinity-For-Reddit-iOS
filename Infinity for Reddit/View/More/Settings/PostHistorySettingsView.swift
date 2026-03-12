//
// PostHistorySettingsView.swift
// Infinity for Reddit
//
// Created by joeylr2042 on 2024-12-04
//

import SwiftUI
import Swinject
import GRDB

struct PostHistorySettingsView: View {
    @AppStorage(PostHistoryUserDefaultsUtils.saveReadPostsKey, store: .postHistory)
    private var saveReadPosts: Bool = false
    
    @AppStorage(PostHistoryUserDefaultsUtils.limitHistorySizeKey, store: .postHistory)
    private var limitHistorySize: Bool = true
    
    @AppStorage(PostHistoryUserDefaultsUtils.historyLimitKey, store: .postHistory)
    private var historyLimit: Int = 500
    
    @AppStorage(PostHistoryUserDefaultsUtils.markPostsAsReadAfterVotingKey, store: .postHistory)
    private var markPostsAsReadAfterVoting: Bool = false
    
    @AppStorage(PostHistoryUserDefaultsUtils.markPostsAsReadOnScrollKey, store: .postHistory)
    private var markPostsAsReadOnScroll: Bool = false
    
    @AppStorage(PostHistoryUserDefaultsUtils.hideReadPostsKey, store: .postHistory)
    private var hideReadPosts: Bool = false
    
    @FocusState private var focusedField: FieldType?
    
    var body: some View {
        RootView {
            VStack(spacing: 0) {
                ScrollViewReader { proxy in
                    List {
                        TogglePreference(isEnabled: $saveReadPosts, title: "Save Read Posts")
                            .listPlainItemNoInsets()
                        
                        TogglePreference(isEnabled: $limitHistorySize, title: "Limit History Size")
                            .listPlainItemNoInsets()
                        
                        if limitHistorySize {
                            CustomTextField(
                                "History Limit",
                                text: Binding(
                                    get: { String(self.historyLimit) },
                                    set: { self.historyLimit = Int($0) ?? 500 }
                                ),
                                singleLine: true,
                                keyboardType: .numberPad,
                                fieldType: .historyLimit,
                                focusedField: $focusedField
                            )
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .listPlainItemNoInsets()
                            .limitedWidth()
                            .transition(.move(edge: .trailing).combined(with: .opacity))
                            .id(FieldType.historyLimit)
                        }
                        
                        if saveReadPosts {
                            TogglePreference(isEnabled: $markPostsAsReadAfterVoting, title: "Mark Posts as Read After Voting")
                                .listPlainItemNoInsets()

                            TogglePreference(isEnabled: $markPostsAsReadOnScroll, title: "Mark Posts As Read on Scroll")
                                .listPlainItemNoInsets()

                            TogglePreference(isEnabled: $hideReadPosts, title: "Hide Read Posts Automatically")
                                .listPlainItemNoInsets()
                        }
                    }
                    .themedList()
                    .onChange(of: focusedField) { oldField, newField in
                        guard let field = newField else { return }
                        DispatchQueue.main.async {
                            withAnimation {
                                proxy.scrollTo(field, anchor: .center)
                            }
                        }
                    }
                }
                .animation(.easeInOut, value: saveReadPosts)
                
                KeyboardToolbar {
                    focusedField = nil
                }
            }
        }
        .themedNavigationBar()
        .addTitleToInlineNavigationBar("Post History")
    }
    
    private enum FieldType: Hashable {
        case historyLimit
    }
}
