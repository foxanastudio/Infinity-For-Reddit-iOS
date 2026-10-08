//
//  CreateModMailConversationView.swift
//  Infinity for Reddit
//
//  Created by joeylr2042 on 2026-09-10.
//

import SwiftUI

struct CreateModMailConversationView: View {
    @StateObject private var createModMailConversationViewModel: CreateModMailConversationViewModel
    
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
                    
                    ModMailSubredditChooserView(
                        selectedSubreddit: createModMailConversationViewModel.selectedSubreddit,
                        labelWidth: labelWidth
                    ) {
                        createModMailConversationViewModel.selectedSubreddit = $0
                    }
                    
                    CustomDivider()
                }
            }
        }
        .themedNavigationBar()
        .addTitleToInlineNavigationBar("Create Mod Mail")
    }
}
