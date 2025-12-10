//
//  CommentFilterUsageSheet.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-08-06.
//

import SwiftUI

struct CommentFilterUsageSheet: View {
    @Environment(\.dismiss) var dismiss
    
    @FocusState private var focusedField: FieldType?
    
    @State private var step: Step = .selectUsageType
    @State private var nameOfUsage: String = ""
    
    var onCommentFilterUsageSelected: (CommentFilterUsage.UsageType, String) -> Void
    
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
                                if !trimmed.isEmpty {
                                    onCommentFilterUsageSelected(selectedType, trimmed)
                                    dismiss()
                                }
                            }
                    }
                }
                .padding(16)
                
                switch step {
                    case .selectUsageType:
                    IconTextButton(startIconUrl: "text.bubble", text: "Subreddit") {
                        step = .nameOfUsage(selectedType: .subreddit)
                    }
                    case .nameOfUsage(let selectedType):
                    RowText(selectedType.description)
                        .primaryText()
                        .fontWeight(.bold)
                        .padding(16)
                    
                    RowText("Leave it blank to apply this comment filter to all the subreddits / users / multireddits")
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
            }
        }
    }
    
    private enum Step: Equatable {
        case selectUsageType
        case nameOfUsage(selectedType: CommentFilterUsage.UsageType)
    }
    
    private enum FieldType: Hashable {
        case nameOfUsage
    }
}
