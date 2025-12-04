//
//  CopyCustomFeedView.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-11-23.
//

import SwiftUI

struct CopyCustomFeedView: View {
    @Environment(\.dismiss) private var dismiss
    
    @EnvironmentObject private var accountViewModel: AccountViewModel
    @EnvironmentObject private var navigationManager: NavigationManager
    @EnvironmentObject private var snackbarManager: SnackbarManager
    
    @StateObject private var copyCustomFeedViewModel: CopyCustomFeedViewModel
    
    @FocusState private var focusedField: FieldType?
    
    @State private var descriptionCanFocus: Bool = true
    @State private var descriptionSelectedRange: NSRange = NSRange(location: 0, length: 0)
    
    init(path: String) {
        _copyCustomFeedViewModel = StateObject(
            wrappedValue: CopyCustomFeedViewModel(
                path: path,
                copyCustomFeedRepository: CopyCustomFeedRepository()
            )
        )
    }
    
    var body: some View {
        RootView {
            if !copyCustomFeedViewModel.customFeedLoadState.isLoaded {
                switch copyCustomFeedViewModel.customFeedLoadState {
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
                        copyCustomFeedViewModel.customFeedLoadState = .idle
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            } else {
                VStack(spacing: 0) {
                    ScrollView {
                        LazyVStack(spacing: 0) {
                            CustomTextField(
                                "Name (Max 50 characters)",
                                text: $copyCustomFeedViewModel.name,
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
                                text: $copyCustomFeedViewModel.description,
                                selectedRange: $descriptionSelectedRange,
                                canFocus: $descriptionCanFocus
                            )
                            .contentShape(Rectangle())
                            .padding(16)
                            
                            Divider()
                            
                            ForEach(copyCustomFeedViewModel.subredditsAndUsersInCustomFeed, id: \.id) { item in
                                SubredditAndUserInCustomFeedItemView(
                                    text: item.name,
                                    iconUrlString: item.iconUrlString
                                )
                            }
                        }
                    }
                    
                    KeyboardToolbar {
                        descriptionCanFocus = false
                        focusedField = nil
                    }
                }
            }
        }
        .id(accountViewModel.account.username)
        .themedNavigationBar()
        .addTitleToInlineNavigationBar("Copy Custom Feed")
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Button(action: {
                    copyCustomFeedViewModel.copyCustomFeed()
                }) {
                    SwiftUI.Image(systemName: "checkmark.circle")
                        .navigationBarImage()
                }
            }
        }
        .task {
            await copyCustomFeedViewModel.fetchCustomFeedDetailsToCopy()
        }
        .onChange(of: copyCustomFeedViewModel.copyCustomFeedTask) { _, newValue in
            if newValue != nil {
                snackbarManager.showSnackbar(
                    .info("Copying. Please wait..."),
                    autoDismiss: false,
                    canDismissByGesture: false
                )
            }
        }
        .onChange(of: copyCustomFeedViewModel.copiedMyCustomFeed) { _, newValue in
            if newValue != nil {
                snackbarManager.showSnackbar(.info("Copied"))
                dismiss()
            }
        }
        .showErrorUsingSnackbar(copyCustomFeedViewModel.$error)
    }
    
    private enum FieldType: Hashable {
        case name
    }
}
