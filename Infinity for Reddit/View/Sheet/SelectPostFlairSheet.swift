//
//  SelectPostFlairSheet.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-11-17.
//

import SwiftUI

struct SelectPostFlairSheet: View {
    @Environment(\.dismiss) var dismiss
    
    @FocusState private var focusedField: FieldType?
    
    @State private var showCustomizeFlairTextSheet: Bool = false
    @State private var flairToBeCustomized: Flair?
    
    let flairs: [Flair]?
    let onFlairSelected: (Flair) -> Void
    
    var body: some View {
        SheetRootView {
            ScrollView {
                if let flairs {
                    VStack(spacing: 0) {
                        if !flairs.isEmpty {
                            ForEach(flairs, id: \.id) { flair in
                                TouchRipple(action: {
                                    onFlairSelected(flair)
                                    dismiss()
                                }) {
                                    FlairRowView(flair: flair) {
                                        flairToBeCustomized = flair
                                        withAnimation(.linear(duration: 0.2)) {
                                            showCustomizeFlairTextSheet = true
                                        }
                                    }
                                }
                            }
                        } else {
                            Text("No flairs available")
                                .secondaryText()
                        }
                    }
                    .padding(.top, 20)
                } else {
                    ProgressIndicator()
                }
            }
        }
        .overlay {
            if showCustomizeFlairTextSheet {
                CustomAlert(title: "Customize Post Flair Text", confirmButtonText: "OK", isPresented: $showCustomizeFlairTextSheet) {
                    VStack(spacing: 16) {
                        CustomTextField(
                            "Post Flair Text",
                            text: Binding<String>(
                                get: {
                                    flairToBeCustomized?.text ?? ""
                                }, set: { newValue in
                                    flairToBeCustomized?.text = newValue
                                }
                            ),
                            singleLine: true,
                            autocapitalization: .never,
                            characterLimit: 64,
                            fieldType: .customizePostFilterText,
                            focusedField: $focusedField
                        )
                        .submitLabel(.done)
                        .onSubmit {
                            if let flairToBeCustomized {
                                onFlairSelected(flairToBeCustomized)
                                dismiss()
                            }
                        }
                        
                        RowText("Maximum 64 characters.")
                            .secondaryText()
                    }
                } onConfirm: {
                    if let flairToBeCustomized {
                        onFlairSelected(flairToBeCustomized)
                        dismiss()
                    }
                }
            }
        }
    }
    
    enum FieldType: Hashable {
        case customizePostFilterText
    }
}
