//
//  PostFilterUsageSheet.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-08-04.
//

import SwiftUI

struct PostFilterUsageSheet: View {
    @Environment(\.dismiss) var dismiss
    
    @FocusState private var focusedField: FieldType?
    
    @State private var step: Step = .selectUsageType
    @State private var nameOfUsage: String = ""
    
    var onPostFilterUsageSelected: (PostFilterUsage.UsageType, String?) -> Void
    
    var body: some View {
        SheetRootView {
            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    Text(step == .selectUsageType ? "Cancel" : "Back")
                        .neutralTextButton()
                        .onTapGesture {
                            if case .nameOfUsage = step {
                                step = .selectUsageType
                            } else {
                                dismiss()
                            }
                        }
                    
                    Spacer()
                    
                    if case .nameOfUsage(let selectedType) = step {
                        Text("Save")
                            .positiveTextButton()
                            .onTapGesture {
                                let trimmed = nameOfUsage.trimmingCharacters(in: .whitespacesAndNewlines)
                                onPostFilterUsageSelected(selectedType, trimmed.isEmpty ? nil : trimmed)
                                dismiss()
                            }
                    }
                }
                .padding(16)
                
                switch step {
                    case .selectUsageType:
                    IconTextButton(startIconUrl: "house", text: "Home") {
                        onPostFilterUsageSelected(.home, nil)
                        dismiss()
                    }
                    
                    IconTextButton(startIconUrl: "text.bubble", text: "Subreddit") {
                        step = .nameOfUsage(selectedType: .subreddit)
                    }
                    
                    IconTextButton(startIconUrl: "person.circle", text: "User") {
                        step = .nameOfUsage(selectedType: .user)
                    }
                    
                    IconTextButton(startIconUrl: "rectangle.stack", text: "Custom Feed") {
                        step = .nameOfUsage(selectedType: .customFeed)
                    }
                    
                    IconTextButton(startIconUrl: "magnifyingglass", text: "Search") {
                        onPostFilterUsageSelected(.search, nil)
                        dismiss()
                    }
                    case .nameOfUsage(let selectedType):
                    RowText(selectedType.description)
                        .primaryText()
                        .fontWeight(.bold)
                        .padding(16)
                    
                    RowText("Leave it blank to apply this post filter to all the subreddits / users / multireddits")
                        .primaryText()
                        .padding(16)
                    
                    CustomTextField(selectedType.textFieldPlaceholder,
                                    text: $nameOfUsage,
                                    singleLine: true,
                                    fieldType: .nameOfUsage,
                                    focusedField: $focusedField)
                    .submitLabel(.done)
                    .padding(16)
                }
                
                Spacer()
            }
        }
    }
    
    private enum Step: Equatable {
        case selectUsageType
        case nameOfUsage(selectedType: PostFilterUsage.UsageType)
    }
    
    private enum FieldType: Hashable {
        case nameOfUsage
    }
}
