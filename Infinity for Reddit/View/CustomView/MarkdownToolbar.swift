//
//  MarkdownToolbar.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-08-18.
//

import SwiftUI

struct MarkdownToolbar: View {
    var onBold: () -> Void
    var onItalic: () -> Void
    var onLink: () -> Void

    var body: some View {
        HStack(spacing: 16) {
            Button(action: onBold) {
                Text("B").bold()
            }
            Button(action: onItalic) {
                Text("I").italic()
            }
            Button(action: onLink) {
                SwiftUI.Image(systemName: "link")
            }
        }
        .padding()
        .background(Color.gray.opacity(0.2))
        .cornerRadius(10)
    }
}
