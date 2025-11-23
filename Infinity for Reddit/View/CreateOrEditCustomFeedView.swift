//
//  CreateOrEditCustomFeedView.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-11-19.
//

import SwiftUI

struct CreateOrEditCustomFeedView: View {
    @EnvironmentObject private var accountViewModel: AccountViewModel
    @EnvironmentObject private var navigationManager: NavigationManager
    @EnvironmentObject private var snackbarManager: SnackbarManager
    
    @StateObject private var createOrEditCustomFeedViewModel: CreateOrEditCustomFeedViewModel
    
    @FocusState private var focusedField: FieldType?
    
    @State private var descriptionCanFocus: Bool = true
    @State private var descriptionSelectedRange: NSRange = NSRange(location: 0, length: 0)
    @State private var showSubredditAndUserMultiSelectionSheet: Bool = false
    
    init(myCustomFeedToEdit: MyCustomFeed? = nil) {
        _createOrEditCustomFeedViewModel = StateObject(
            wrappedValue: CreateOrEditCustomFeedViewModel(
                myCustomFeedToEdit: myCustomFeedToEdit,
                createCustomFeedRepository: CreateOrEditCustomFeedRepository()
            )
        )
    }
    
    var body: some View {
        RootView {
            if createOrEditCustomFeedViewModel.myCustomFeedToEdit != nil && !createOrEditCustomFeedViewModel.myCustomFeedToEditLoadState.isLoaded {
                switch createOrEditCustomFeedViewModel.myCustomFeedToEditLoadState {
                case .idle:
                    Color.clear
                case .loading:
                    ZStack {
                        ProgressIndicator()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                case .loaded:
                    // Well it shouldn't reach here
                    Color.clear
                case .failed(let error):
                    ZStack {
                        Text("Failed to load custom feed. Tap to try again. Error: \(error.localizedDescription)")
                            .primaryText()
                    }
                    .onTapGesture {
                        createOrEditCustomFeedViewModel.myCustomFeedToEditLoadState = .idle
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            } else {
                VStack(spacing: 0) {
                    ScrollView {
                        LazyVStack(spacing: 0) {
                            CustomTextField(
                                "Name (Max 50 characters)",
                                text: $createOrEditCustomFeedViewModel.name,
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
                                text: $createOrEditCustomFeedViewModel.description,
                                selectedRange: $descriptionSelectedRange,
                                canFocus: $descriptionCanFocus
                            )
                            .contentShape(Rectangle())
                            .padding(16)
                            
                            if !accountViewModel.account.isAnonymous() {
                                TouchRipple(action: {
                                    createOrEditCustomFeedViewModel.isPrivate.toggle()
                                }) {
                                    HStack {
                                        RowText("Private Custom Feed")
                                            .primaryText()
                                        
                                        Toggle(isOn: $createOrEditCustomFeedViewModel.isPrivate) {}
                                            .labelsHidden()
                                            .themedToggle()
                                            .excludeFromTouchRipple()
                                    }
                                    .padding(16)
                                }
                            }
                            
                            Divider()
                            
                            ForEach(createOrEditCustomFeedViewModel.subredditsAndUsersInCustomFeed, id: \.id) { item in
                                SubredditAndUserInCustomFeedItemView(
                                    text: item.name,
                                    iconUrlString: item.iconUrlString
                                ) {
                                    createOrEditCustomFeedViewModel.removeSubredditAndUserInCustomFeed(item)
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
        }
        .id(accountViewModel.account.username)
        .themedNavigationBar()
        .addTitleToInlineNavigationBar("\(createOrEditCustomFeedViewModel.myCustomFeedToEdit != nil ? "Edit" : "Create") Custom Feed")
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Button(action: {
                    createOrEditCustomFeedViewModel.createOrUpdateCustomFeed()
                }) {
                    SwiftUI.Image(systemName: "checkmark.circle")
                        .navigationBarImage()
                }
                
                NavigationBarMenu()
            }
        }
        .applyIf(createOrEditCustomFeedViewModel.myCustomFeedToEdit != nil) {
            $0.task {
                await createOrEditCustomFeedViewModel.fetchCustomFeedDetailsToEdit()
            }
        }
        .onChange(of: createOrEditCustomFeedViewModel.createOrUpdateCustomFeedTask) { _, newValue in
            if newValue != nil {
                snackbarManager.showSnackbar(
                    text: "Creating. Please wait...",
                    autoDismiss: false,
                    canDismissByGesture: false
                )
            }
        }
        .onChange(of: createOrEditCustomFeedViewModel.createdOrUpdatedMyCustomFeed) { _, newValue in
            if let newValue {
                snackbarManager.dismiss()
                navigationManager.replaceCurrentScreen(AppNavigation.customFeed(myCustomFeed: newValue))
            }
        }
        .onReceive(createOrEditCustomFeedViewModel.$error) { newValue in
            if let error = newValue {
                snackbarManager.showSnackbar(text: error.localizedDescription)
            }
        }
        .sheet(isPresented: $showSubredditAndUserMultiSelectionSheet) {
            NavigationStack {
                SubredditAndUserMultiSelectionSheet(
                    subscriptionSelectionMode: .subredditAndUserMultiSelection(
                        selectedSubredditsAndUsers: createOrEditCustomFeedViewModel.subredditsAndUsersInCustomFeed,
                        onConfirmSelection: { subredditsAndUsersInCustomFeed in
                            createOrEditCustomFeedViewModel.addSubredditsAndUsersInCustomFeed(subredditsAndUsersInCustomFeed)
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
