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
    
    init() {
        _createCustomFeedViewModel = StateObject(wrappedValue: CreateCustomFeedViewModel(createCustomFeedRepository: CreateCustomFeedRepository()))
    }
    
    var body: some View {
        RootView {
            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: 0) {
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
                        
                        Divider()
                    }
                }
                
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
                    text: "Sending. Please wait...",
                    autoDismiss: false,
                    canDismissByGesture: false
                )
            }
        }
        .onChange(of: createCustomFeedViewModel.customFeedCreatedFlag) { _, newValue in
            if newValue {
                
            }
        }
        .onReceive(createCustomFeedViewModel.$error) { newValue in
            if let error = newValue {
                snackbarManager.showSnackbar(text: error.localizedDescription)
            }
        }
    }
    
    private enum FieldType: Hashable {
        case name
    }
}
