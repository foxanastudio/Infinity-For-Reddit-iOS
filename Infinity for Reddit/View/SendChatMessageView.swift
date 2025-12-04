//
//  SendChatMessageView.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-11-19.
//

import SwiftUI

struct SendChatMessageView: View {
    @Environment(\.dismiss) private var dismiss
    
    @EnvironmentObject private var accountViewModel: AccountViewModel
    @EnvironmentObject private var navigationManager: NavigationManager
    @EnvironmentObject private var snackbarManager: SnackbarManager
    
    @StateObject private var sendChatMessageViewModel: SendChatMessageViewModel
    
    @FocusState private var focusedField: FieldType?
    
    @State private var subjectCanFocus: Bool = true
    @State private var messageCanFocus: Bool = true
    @State private var subjectSelectedRange: NSRange = NSRange(location: 0, length: 0)
    @State private var messageSelectedRange: NSRange = NSRange(location: 0, length: 0)
    
    init(recipient: String?) {
        _sendChatMessageViewModel = StateObject(wrappedValue: SendChatMessageViewModel(recipient: recipient, sendChatMessageRepository: SendChatMessageRepository()))
    }
    
    var body: some View {
        RootView {
            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: 0) {
                        CustomTextField(
                            "Recipient",
                            text: $sendChatMessageViewModel.recipient,
                            singleLine: true,
                            keyboardType: .default,
                            autocapitalization: .never,
                            showBorder: false,
                            fieldType: .recipient,
                            focusedField: $focusedField
                        )
                        .padding(.horizontal, 16)
                        .padding(.top, 16)
                        
                        MarkdownTextField(
                            hint: "Subject",
                            text: $sendChatMessageViewModel.subject,
                            selectedRange: $subjectSelectedRange,
                            canFocus: $subjectCanFocus
                        )
                        .contentShape(Rectangle())
                        .padding(16)
                        
                        Divider()
                        
                        MarkdownTextField(
                            hint: "Message",
                            text: $sendChatMessageViewModel.message,
                            selectedRange: $messageSelectedRange,
                            canFocus: $messageCanFocus
                        )
                        .contentShape(Rectangle())
                        .padding(16)
                    }
                }
                
                KeyboardToolbar {
                    subjectCanFocus = false
                    messageCanFocus = false
                    focusedField = nil
                }
            }
        }
        .id(accountViewModel.account.username)
        .themedNavigationBar()
        .addTitleToInlineNavigationBar("Send Chat Message")
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Button(action: {
                    sendChatMessageViewModel.sendChatMessage()
                }) {
                    SwiftUI.Image(systemName: "paperplane.fill")
                        .navigationBarImage()
                }
                
                NavigationBarMenu()
            }
        }
        .onChange(of: sendChatMessageViewModel.sendChatMessageTask) { _, newValue in
            if newValue != nil {
                snackbarManager.showSnackbar(
                    .info("Sending. Please wait..."),
                    autoDismiss: false,
                    canDismissByGesture: false
                )
            }
        }
        .onChange(of: sendChatMessageViewModel.chatMessageSentFlag) { _, newValue in
            if newValue {
                snackbarManager.showSnackbar(.info("Sent"))
                dismiss()
            }
        }
        .showErrorUsingSnackbar(sendChatMessageViewModel.$error)
    }
    
    private enum FieldType: Hashable {
        case recipient
    }
}
