//
// SubmitTextPostView.swift
// Infinity for Reddit
//
// Created by joeylr2042 on 2025-08-21

import SwiftUI
        
struct SubmitTextPostView: View {
    @EnvironmentObject private var navigationManager: NavigationManager
    @EnvironmentObject private var subredditChooseViewModel: SubredditChooseViewModel
    @StateObject private var submitTextPostViewModel: SubmitTextPostViewModel
    
    @State private var selectedRange: NSRange = NSRange(location: 0, length: 0)
    @State private var toolbarHeight: CGFloat = 0
    @State private var receiveReplyNotification: Bool = false
    @State private var showSelectSubredditView: Bool = false
    
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
                
                Toggle(isOn: $receiveReplyNotification) {
                    Text("Receive post reply notifications")
                        .secondaryText()
                }
                .padding(16)
                .themedToggle()
                
                Divider()
                
                ZStack(alignment: .topLeading) {
                    MarkdownTextField(text: $submitTextPostViewModel.text, selectedRange: $selectedRange)
                        .frame(maxHeight: 10)
                    
                    if submitTextPostViewModel.text.isEmpty {
                        Text("Title")
                            .primaryText()
                    }
                }
                .padding(16)
                
                ZStack(alignment: .topLeading) {
                    MarkdownTextField(text: $submitTextPostViewModel.text, selectedRange: $selectedRange)
                        .frame(minHeight: 300)
                    
                    if submitTextPostViewModel.text.isEmpty {
                        Text("Content")
                            .secondaryText()
                    }
                }
                .padding(16)
                
                Spacer()
            }
            
            MarkdownToolbar(
                text: $submitTextPostViewModel.text,
                selectedRange: $selectedRange,
                toolbarHeight: $toolbarHeight
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
    }
}
