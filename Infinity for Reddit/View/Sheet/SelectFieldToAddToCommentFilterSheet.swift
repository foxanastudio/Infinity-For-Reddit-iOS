//
//  SelectFieldToAddToCommentFilterSheet.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-11-19.
//

import SwiftUI

struct SelectFieldToAddToCommentFilterSheet: View {
    @Environment(\.dismiss) private var dismiss
    
    @State var selectedFieldsToAddToCommentFilter: [SelectedFieldToAddToCommentFilter] = []
    @State private var selections: Set<SelectedFieldToAddToCommentFilter> = Set()

    var fields: [SelectedFieldToAddToCommentFilter]? = nil
    let onConfirm: ([SelectedFieldToAddToCommentFilter]) -> Void
    
    var body: some View {
        SheetRootView {
            VStack(spacing: 0) {
                Spacer()
                    .frame(height: 20)
                
                RowText("Select fields to add to comment filter")
                    .fontWeight(.bold)
                    .padding(16)
                
                ForEach(fields != nil && !fields!.isEmpty ? fields! : SelectedFieldToAddToCommentFilter.allCases, id: \.self) { field in
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

enum SelectedFieldToAddToCommentFilter: CaseIterable {
    case excludeUser
    case containUser
    
    var fullName: String {
        switch self {
        case .excludeUser:
            return "Exclude user"
        case .containUser:
            return "Contain user"
        }
    }
}
