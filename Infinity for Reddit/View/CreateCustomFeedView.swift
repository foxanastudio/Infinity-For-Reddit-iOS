//
//  CreateCustomFeedView.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-11-19.
//

import SwiftUI

struct CreateCustomFeedView: View {
    @EnvironmentObject private var accountViewModel: AccountViewModel
    @EnvironmentObject private var navigationManager: NavigationManager
    @EnvironmentObject private var snackbarManager: SnackbarManager
    
    @StateObject private var createCustomFeedViewModel: CreateCustomFeedViewModel
    
    @FocusState private var focusedField: FieldType?
    
    @State private var descriptionCanFocus: Bool = true
    @State private var descriptionSelectedRange: NSRange = NSRange(location: 0, length: 0)
    @State private var showSubredditAndUserMultiSelectionSheet: Bool = false
    
    init() {
        _createCustomFeedViewModel = StateObject(wrappedValue: CreateCustomFeedViewModel(createCustomFeedRepository: CreateCustomFeedRepository()))
    }
    
    var body: some View {
        RootView {
            VStack(spacing: 0) {
                ScrollView {
                    LazyVStack(spacing: 0) {
                        CustomTextField(
                            "Name (Max 50 characters)",
                            text: $createCustomFeedViewModel.name,
                            singleLine: true,
                            keyboardType: .default,
                            autocapitalization: .never,
                            showBorder: false,
                            fieldType: .name,
                            focusedField: $focusedField
                        )
                        .padding(.horizontal, 16)
                        .padding(.top, 16)
                        
                        MarkdownTextField(
                            hint: "Description",
                            text: $createCustomFeedViewModel.description,
                            selectedRange: $descriptionSelectedRange,
                            canFocus: $descriptionCanFocus
                        )
                        .contentShape(Rectangle())
                        .padding(16)
                        
                        if !accountViewModel.account.isAnonymous() {
                            TouchRipple(action: {
                                createCustomFeedViewModel.isPrivate.toggle()
                            }) {
                                HStack {
                                    RowText("Private Custom Feed")
                                        .primaryText()
                                    
                                    Toggle(isOn: $createCustomFeedViewModel.isPrivate) {}
                                        .labelsHidden()
                                        .themedToggle()
                                        .excludeFromTouchRipple()
                                }
                                .padding(16)
                            }
                        }
                        
                        Divider()
                        
                        ForEach(createCustomFeedViewModel.subredditsAndUsersInCustomFeed, id: \.id) { item in
                            SubredditAndUserInCustomFeedItemView(
                                text: item.name,
                                iconUrlString: item.iconUrlString
                            ) {
                                createCustomFeedViewModel.removeSubredditAndUserInCustomFeed(item)
                            }
                        }
                    }
                }
                
                Button {
                    showSubredditAndUserMultiSelectionSheet = true
                } label: {
                    HStack {
                        Text("Select Subreddit(s) and User(s)")
                    }
                    .frame(maxWidth: .infinity)
                }
                .padding(16)
                .filledButton()
                
                KeyboardToolbar {
                    descriptionCanFocus = false
                    focusedField = nil
                }
            }
        }
        .id(accountViewModel.account.username)
        .themedNavigationBar()
        .addTitleToInlineNavigationBar("Create Custom Feed")
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Button(action: {
                    createCustomFeedViewModel.createCustomFeed()
                }) {
                    SwiftUI.Image(systemName: "checkmark.circle")
                        .navigationBarImage()
                }
                
                NavigationBarMenu()
            }
        }
        .onChange(of: createCustomFeedViewModel.createCustomFeedTask) { _, newValue in
            if newValue != nil {
                snackbarManager.showSnackbar(
                    text: "Creating. Please wait...",
                    autoDismiss: false,
                    canDismissByGesture: false
                )
            }
        }
        .onChange(of: createCustomFeedViewModel.createdMyCustomFeed) { _, newValue in
            if let newValue {
                snackbarManager.dismiss()
                navigationManager.replaceCurrentScreen(AppNavigation.customFeed(myCustomFeed: newValue))
            }
        }
        .onReceive(createCustomFeedViewModel.$error) { newValue in
            if let error = newValue {
                snackbarManager.showSnackbar(text: error.localizedDescription)
            }
        }
        .sheet(isPresented: $showSubredditAndUserMultiSelectionSheet) {
            NavigationStack {
                SubredditAndUserMultiSelectionSheet(
                    subscriptionSelectionMode: .subredditAndUserMultiSelection(
                        selectedSubredditsAndUsers: createCustomFeedViewModel.subredditsAndUsersInCustomFeed,
                        onConfirmSelection: { subredditsAndUsersInCustomFeed in
                            createCustomFeedViewModel.addSubredditsAndUsersInCustomFeed(subredditsAndUsersInCustomFeed)
                        }
                    )
                )
            }
        }
    }
    
    private enum FieldType: Hashable {
        case name
    }
    
    struct SubredditAndUserInCustomFeedItemView: View {
        var text: String
        var iconUrlString: String?
        var iconSize: CGFloat = 24
        let onDelete: () -> Void
        
        var body: some View {
            HStack(spacing: 0) {
                if let icon = iconUrlString {
                    CustomWebImage(
                        icon,
                        width: iconSize,
                        height: iconSize,
                        circleClipped: true,
                        handleImageTapGesture: false,
                        fallbackView: {
                            InitialLetterAvatarImageFallbackView(name: text, size: iconSize)
                        }
                    )
                } else {
                    Spacer()
                        .frame(width: iconSize)
                }
                
                Spacer()
                    .frame(width: 24)
                
                Text(text)
                    .primaryText()
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Button(action: {
                    onDelete()
                }) {
                    SwiftUI.Image(systemName: "trash")
                        .primaryIcon()
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
            .contentShape(Rectangle())
        }
    }
}
