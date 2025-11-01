//
// LayoutTypeSheet.swift
// Infinity for Reddit
//
// Created by joeylr2042 on 2025-10-29

import SwiftUI

struct LayoutTypeSheet: View {
    @Environment(\.dismiss) var dismiss
    
    let currentLayout: PostLayoutType
    let onSelectLayout: (PostLayoutType) -> Void
    let onResetLayout: () -> Void
    private let availableLayouts: [PostLayoutType] = [.card, .compact]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                Text("Select Post Layout")
                    .font(.headline)
                    .padding(.bottom, 16)
                
                ForEach(availableLayouts, id: \.self) { layout in
                    IconTextButton(
                        startIconUrl: layout.icon,
                        startIconType: .systemIcon,
                        endIconUrl: layout == currentLayout ? "checkmark.seal" : nil,
                        endIconType: .systemIcon,
                        text: layout.fullName
                    ) {
                        onSelectLayout(layout)
                        dismiss()
                    }
                    .listPlainItemNoInsets()
                }
                
                // Debug
                IconTextButton(
                    startIconUrl: "arrow.counterclockwise",
                    startIconType: .systemIcon,
                    text: "Reset to Default Layout"
                ) {
                    onResetLayout()
                    dismiss()
                }
                .listPlainItemNoInsets()
            }
            .padding(.top, 24)
        }
    }
}
