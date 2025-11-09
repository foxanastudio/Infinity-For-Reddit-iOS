//
// PostLayoutSheet.swift
// Infinity for Reddit
//
// Created by joeylr2042 on 2025-10-29

import SwiftUI

struct PostLayoutSheet: View {
    @Environment(\.dismiss) var dismiss
    
    let currentPostLayout: PostLayout
    let onSelectPostLayout: (PostLayout) -> Void
    private let availablePostLayouts: [PostLayout] = [.card, .compact]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                Text("Select Post Layout")
                    .padding(.bottom, 16)
                
                ForEach(availablePostLayouts, id: \.self) { postLayout in
                    IconTextButton(
                        startIconUrl: postLayout.icon,
                        endIconUrl: postLayout == currentPostLayout ? "checkmark.seal" : nil,
                        text: postLayout.fullName
                    ) {
                        onSelectPostLayout(postLayout)
                        dismiss()
                    }
                    .listPlainItemNoInsets()
                }
            }
            .padding(.top, 24)
        }
    }
}
