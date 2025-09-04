//
// SubmitTextPostView.swift
// Infinity for Reddit
//
// Created by joeylr2042 on 2025-08-21

import SwiftUI
        
struct SubmitTextPostView: View {
    @EnvironmentObject private var navigationManager: NavigationManager
    @EnvironmentObject private var subredditChooseViewModel: SubredditChooseViewModel
    @EnvironmentObject private var themeViewModel: CustomThemeViewModel
    @StateObject private var submitTextPostViewModel: SubmitTextPostViewModel
    
    @FocusState private var markdownToolbarFocusedField: MarkdownFieldType?
    
    @State private var selectedRange: NSRange = NSRange(location: 0, length: 0)
    @State private var titleTextViewCanFocus: Bool = true
    @State private var contentTextViewCanFocus: Bool = true
    @State private var markdownToolbarHeight: CGFloat = 0
    @State private var receiveReplyNotification: Bool = false
    @State private var showSelectSubredditView: Bool = false
    @State private var showFlairSheet: Bool = false
    @State private var isSpoiler: Bool = false
    
    init() {
        _submitTextPostViewModel = StateObject(
            wrappedValue: SubmitTextPostViewModel()
        )
    }
    
    var body: some View {
        ZStack {
            VStack {
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
                            showFlairSheet = true
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
                
                ZStack(alignment: .topLeading) {
                    MarkdownTextField(text: $submitTextPostViewModel.title, selectedRange: $selectedRange, canFocus: $titleTextViewCanFocus)
                        .frame(maxHeight: 10)
                    
                    if submitTextPostViewModel.title.isEmpty {
                        Text("Title")
                            .secondaryText()
                            .bold()
                    }
                }
                .padding(16)
                
                ZStack(alignment: .topLeading) {
                    MarkdownTextField(text: $submitTextPostViewModel.content, selectedRange: $selectedRange, canFocus: $contentTextViewCanFocus)
                        .frame(minHeight: 300)
                    
                    if submitTextPostViewModel.content.isEmpty {
                        Text("Content")
                            .secondaryText()
                    }
                }
                .padding(16)
                
                Spacer()
            }
            
            MarkdownToolbar(
                text: $submitTextPostViewModel.content,
                selectedRange: $selectedRange,
                toolbarHeight: $markdownToolbarHeight,
                focusedField: $markdownToolbarFocusedField
            )
        }
        .themedNavigationBar()
        .addTitleToInlineNavigationBar("Text Post")
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Button {
                    
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
    }
}
