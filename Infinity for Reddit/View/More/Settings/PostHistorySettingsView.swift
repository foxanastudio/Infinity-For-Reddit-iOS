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
    @AppStorage(PostHistoryUserDefaultsUtils.markPostsAsReadKey, store: .postHistory)
    private var markPostsAsRead: Bool = false
    
    @AppStorage(PostHistoryUserDefaultsUtils.limitReadPostsKey, store: .postHistory)
    private var limitReadPosts: Bool = true
    
    @AppStorage(PostHistoryUserDefaultsUtils.readPostsLimitKey, store: .postHistory)
    private var readPostsLimit: Int = 500
    
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
                    ScrollView {
                        TogglePreference(isEnabled: $markPostsAsRead, title: "Mark Posts as Read")
                            .listPlainItemNoInsets()
                        
                        TogglePreference(isEnabled: $limitReadPosts, title: "Limit Read Posts")
                            .listPlainItemNoInsets()
                        
                        if limitReadPosts {
                            CustomTextField(
                                "Read Posts Limit",
                                text: Binding(
                                    get: { String(self.readPostsLimit) },
                                    set: { self.readPostsLimit = Int($0) ?? 500 }
                                ),
                                singleLine: true,
                                keyboardType: .numberPad,
                                fieldType: .readPostsLimit,
                                focusedField: $focusedField
                            )
                            .padding(.leading, 60)
                            .padding(.trailing, 16)
                            .padding(.vertical, 8)
                            .listPlainItemNoInsets()
                            .transition(.move(edge: .trailing).combined(with: .opacity))
                            .id(FieldType.readPostsLimit)
                        }

                        TogglePreference(isEnabled: $markPostsAsReadAfterVoting, title: "Mark Posts as Read After Voting")
                            .listPlainItemNoInsets()

                        TogglePreference(isEnabled: $markPostsAsReadOnScroll, title: "Mark Posts As Read on Scroll")
                            .listPlainItemNoInsets()

                        TogglePreference(isEnabled: $hideReadPosts, title: "Hide Read Posts")
                            .listPlainItemNoInsets()
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
                
                KeyboardToolbar {
                    focusedField = nil
                }
            }
        }
        .themedNavigationBar()
        .addTitleToInlineNavigationBar("Post History")
    }
    
    private enum FieldType: Hashable {
        case readPostsLimit
    }
}
