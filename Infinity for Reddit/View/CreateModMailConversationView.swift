//
//  CreateModMailConversationView.swift
//  Infinity for Reddit
//
//  Created by joeylr2042 on 2026-09-10.
//

import SwiftUI

struct CreateModMailConversationView: View {
    @StateObject private var createModMailConversationViewModel: CreateModMailConversationViewModel
    
    @FocusState private var focusedField: FieldType?
    
    private let labelWidth: CGFloat = 56
    
    init() {
        _createModMailConversationViewModel = StateObject(
            wrappedValue: CreateModMailConversationViewModel(
                createModMailConversationRepository: CreateModMailConversationRepository()
            )
        )
    }
    
    var body: some View {
        RootView {
            ScrollView {
                VStack(spacing: 0) {
                    HStack(spacing: 0) {
                        Text("To")
                            .secondaryText()
                            .frame(width: labelWidth, alignment: .leading)
                        
                        Spacer()
                            .frame(width: 10)
                        
                        SegmentedPicker(
                            selectedValue: Binding(
                                get: { createModMailConversationViewModel.recipientType.rawValue },
                                set: { createModMailConversationViewModel.recipientType = ModMailRecipientType(rawValue: $0) ?? .moderators }
                            ),
                            values: ModMailRecipientType.allCases.map(\.title)
                        )
                        
                        Spacer(minLength: 0)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    
                    if createModMailConversationViewModel.recipientType != .moderators {
                        HStack(spacing: 0) {
                            Spacer()
                                .frame(width: labelWidth + 18)
                            
                            CustomTextField(
                                createModMailConversationViewModel.recipientType == .user ? "u/Username" : "r/Community name",
                                text: $createModMailConversationViewModel.recipient,
                                singleLine: true,
                                keyboardType: .default,
                                autocapitalization: .never,
                                showBorder: false,
                                fieldType: .recipient,
                                focusedField: $focusedField
                            )
                            .submitLabel(.done)
                            
                            Spacer()
                                .frame(width: 16)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                    }
                    
                    ModMailSubredditChooserView(
                        selectedSubreddit: createModMailConversationViewModel.selectedSubreddit,
                        labelWidth: labelWidth
                    ) {
                        createModMailConversationViewModel.selectedSubreddit = $0
                    }
                    
                    if createModMailConversationViewModel.recipientType == .user {
                        HStack(spacing: 0) {
                            Text("As")
                                .secondaryText()
                                .frame(width: labelWidth, alignment: .leading)
                            
                            Spacer()
                                .frame(width: 12)
                            
                            SegmentedPicker(
                                selectedValue: Binding(
                                    get: { createModMailConversationViewModel.isAuthorHidden ? 0 : 1 },
                                    set: { createModMailConversationViewModel.isAuthorHidden = $0 == 0 }
                                ),
                                values: ["Mod Team", "u/\(AccountViewModel.shared.account.username)"]
                            )
                            
                            Spacer(minLength: 0)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                    }
                    
                    CustomDivider()
                }
            }
        }
        .themedNavigationBar()
        .addTitleToInlineNavigationBar("Create Mod Mail")
    }
    
    private enum FieldType: Hashable {
        case recipient
    }
}
