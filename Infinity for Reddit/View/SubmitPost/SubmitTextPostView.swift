//
// SubmitTextPostView.swift
// Infinity for Reddit
//
// Created by joeylr2042 on 2025-08-21

import SwiftUI
import MarkdownUI

struct SubmitTextPostView: View {
    @EnvironmentObject private var navigationManager: NavigationManager
    @EnvironmentObject private var subredditChooseViewModel: SubredditChooseViewModel
    @EnvironmentObject private var themeViewModel: CustomThemeViewModel
    @StateObject private var submitTextPostViewModel: SubmitTextPostViewModel
    
    @FocusState private var markdownToolbarFocusedField: MarkdownFieldType?
    @FocusState private var focusedField: FieldType?
    
    @State private var titleTextViewCanFocus: Bool = true
    @State private var contentTextViewCanFocus: Bool = true
    @State private var markdownToolbarHeight: CGFloat = 0
    @State private var receiveReplyNotification: Bool = false
    @State private var showSelectSubredditView: Bool = false
    @State private var showFlairSheet: Bool = false
    @State private var isSpoiler: Bool = false
    @State private var isNSFW: Bool = false
    @State private var titleSelectedRange: NSRange = NSRange(location: 0, length: 0)
    @State private var bodySelectedRange: NSRange = NSRange(location: 0, length: 0)
    @State private var showMarkdownPreview: Bool = false
    
    init() {
        _submitTextPostViewModel = StateObject(
            wrappedValue: SubmitTextPostViewModel()
        )
    }
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                VStack(spacing: 0) {
                    ScrollView {
                        VStack(spacing: 0) {
                            UserPicker {
                                submitTextPostViewModel.selectedAccount = $0
                            }
                            
                            SubredditChooseView(text: "Choose a subreddit", iconUrl: nil, action: {
                                navigationManager.path.append(AppNavigation.chooseSubredditForNewPost)
                            })
                            .environmentObject(subredditChooseViewModel)
                            .environmentObject(navigationManager)
                            
                            Divider()
                            
                            HStack(spacing: 16) {
                                if !subredditChooseViewModel.flairs.isEmpty {
                                    Button(action: {
                                        if submitTextPostViewModel.selectedFlair != nil {
                                            submitTextPostViewModel.selectedFlair = nil
                                        } else {
                                            showFlairSheet = true
                                        }
                                    }) {
                                        Text(submitTextPostViewModel.selectedFlair?.text ?? "Flair")
                                            .themedPillButton(
                                                isSelected: submitTextPostViewModel.selectedFlair != nil,
                                                selectedBackGround: themeViewModel.currentCustomTheme.flairBackgroundColor,
                                                selectedForeGround: themeViewModel.currentCustomTheme.flairTextColor,
                                                defaultBackGround: themeViewModel.currentCustomTheme.backgroundColor,
                                                defaultForeGround: themeViewModel.currentCustomTheme.primaryTextColor,
                                                defaultBorder: themeViewModel.currentCustomTheme.primaryTextColor
                                            )
                                        
                                    }
                                }
                                
                                Button(action: {
                                    isSpoiler.toggle()
                                }) {
                                    Text("Spoiler")
                                        .themedPillButton(
                                            isSelected: isSpoiler,
                                            selectedBackGround: themeViewModel.currentCustomTheme.spoilerBackgroundColor,
                                            selectedForeGround: themeViewModel.currentCustomTheme.spoilerTextColor,
                                            defaultBackGround: themeViewModel.currentCustomTheme.backgroundColor,
                                            defaultForeGround: themeViewModel.currentCustomTheme.primaryTextColor,
                                            defaultBorder: themeViewModel.currentCustomTheme.primaryTextColor
                                        )
                                }
                                
                                if submitTextPostViewModel.subredditAllowsNSFW {
                                    Button(action: {
                                        isNSFW.toggle()
                                    }) {
                                        Text("Sensitive")
                                            .themedPillButton(
                                                isSelected: isNSFW,
                                                selectedBackGround: themeViewModel.currentCustomTheme.nsfwBackgroundColor,
                                                selectedForeGround: themeViewModel.currentCustomTheme.nsfwTextColor,
                                                defaultBackGround: themeViewModel.currentCustomTheme.backgroundColor,
                                                defaultForeGround: themeViewModel.currentCustomTheme.primaryTextColor,
                                                defaultBorder: themeViewModel.currentCustomTheme.primaryTextColor
                                            )
                                    }
                                }
                                
                                Spacer()
                            }
                            .padding(16)
                            
                            Toggle(isOn: $receiveReplyNotification) {
                                Text("Receive post reply notifications")
                                    .secondaryText()
                            }
                            .padding(16)
                            .themedToggle()
                            
                            Divider()
                            
                            CustomTextField(
                                "Title",
                                text: $submitTextPostViewModel.title,
                                singleLine: true,
                                keyboardType: .default,
                                showBorder: false,
                                fieldType: .title,
                                focusedField: $focusedField
                            )
                            .padding(16)
                            
                            ZStack(alignment: .topLeading) {
                                MarkdownTextField(text: $submitTextPostViewModel.content, selectedRange: $bodySelectedRange, canFocus: $contentTextViewCanFocus)
                                    .frame(minHeight: 300)
                                    .contentShape(Rectangle())
                                
                                if submitTextPostViewModel.content.isEmpty {
                                    Text("Content")
                                        .secondaryText()
                                }
                            }
                            .padding(16)
                        }
                    }
                    
                    Spacer().frame(height: markdownToolbarHeight)
                    
                }
                
                MarkdownToolbar(
                    text: $submitTextPostViewModel.content,
                    selectedRange: $bodySelectedRange,
                    toolbarHeight: $markdownToolbarHeight,
                    focusedField: $markdownToolbarFocusedField
                )
            }
            
            KeyboardToolbar {
                contentTextViewCanFocus = false
                markdownToolbarFocusedField = nil
                focusedField = nil
            }
        }
        .frame(maxHeight: .infinity)
        .themedNavigationBar()
        .addTitleToInlineNavigationBar("Text Post")
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Button {
                    showMarkdownPreview = true
                } label: {
                    SwiftUI.Image(systemName: "eye")
                }
                
                Button {
                    print("Submit Text Post")
                } label: {
                    SwiftUI.Image(systemName: "paperplane.fill")
                }
            }
        }
        .sheet(isPresented: $showFlairSheet) {
            CustomNavigationStack {
                FlairChooseSheet()
                    .presentationDetents([.medium, .large])
                    .presentationDragIndicator(.visible)
                    .environmentObject(subredditChooseViewModel)
                    .environmentObject(submitTextPostViewModel)
            }
            
        }
        .onChange(of: subredditChooseViewModel.selectedSubreddit?.name ?? "") { _, _ in
            submitTextPostViewModel.selectedFlair = nil
            isSpoiler = false
            isNSFW = false
        }
        .sheet(isPresented: $showMarkdownPreview) {
            MarkdownViewerSheet(markdown: submitTextPostViewModel.content)
        }
    }
    
    private enum FieldType: Hashable {
        case title
    }
}
