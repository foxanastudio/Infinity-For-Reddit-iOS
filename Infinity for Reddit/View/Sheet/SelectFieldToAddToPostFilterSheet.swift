//
//  SelectFieldToAddToPostFilterSheet.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-11-18.
//

import SwiftUI

struct SelectFieldToAddToPostFilterSheet: View {
    @Environment(\.dismiss) private var dismiss
    
    @State var selectedFieldsToAddToPostFilter: [SelectedFieldToAddToPostFilter] = []
    @State private var selections: Set<SelectedFieldToAddToPostFilter> = Set()

    var fields: [SelectedFieldToAddToPostFilter]? = nil
    let onConfirm: ([SelectedFieldToAddToPostFilter]) -> Void
    
    var body: some View {
        SheetRootView {
            VStack(spacing: 0) {
                Spacer()
                    .frame(height: 20)
                
                RowText("Select fields to add to post filter")
                    .fontWeight(.bold)
                    .padding(16)
                
                ForEach(fields != nil && !fields!.isEmpty ? fields! : SelectedFieldToAddToPostFilter.allCases, id: \.self) { field in
                    TouchRipple {
                        Button(action: {
                            if selections.contains(field) {
                                selections.remove(field)
                            } else {
                                selections.insert(field)
                            }
                        }, label: {
                            HStack(spacing: 0) {
                                SwiftUI.Image(systemName: selections.contains(field) ? "checkmark.square" : "square")
                                    .primaryIcon()
                                
                                Spacer()
                                    .frame(width: 16)
                                
                                Text(field.fullName)
                                    .primaryText()
                                
                                Spacer()
                            }
                            .padding(16)
                            .contentShape(Rectangle())
                        })
                    }
                }
                
                Button {
                    onConfirm(Array(selections))
                    dismiss()
                } label: {
                    HStack {
                        Text("Done")
                    }
                    .frame(maxWidth: .infinity)
                }
                .padding(16)
                .filledButton()
            }
        }
    }
}

enum SelectedFieldToAddToPostFilter: CaseIterable {
    case excludeSubreddit
    case containSubreddit
    case excludeUser
    case containUser
    case excludeFlair
    case containFlair
    case excludeDomain
    case containDomain
    
    var fullName: String {
        switch self {
        case .excludeSubreddit:
            return "Exclude subreddit"
        case .containSubreddit:
            return "Contain subreddit"
        case .excludeUser:
            return "Exclude user"
        case .containUser:
            return "Contain user"
        case .excludeFlair:
            return "Exclude flair"
        case .containFlair:
            return "Contain flair"
        case .excludeDomain:
            return "Exclude domain"
        case .containDomain:
            return "Contain domain"
        }
    }
}
