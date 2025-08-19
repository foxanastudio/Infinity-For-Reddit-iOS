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
        ScrollView(.horizontal) {
            HStack(spacing: 16) {
                Button(action: onBold) {
                    SwiftUI.Image(systemName: "bold")
                        .primaryIcon()
                }
                
                Button(action: onItalic) {
                    SwiftUI.Image(systemName: "italic")
                        .primaryIcon()
                }
                
                Button(action: onLink) {
                    SwiftUI.Image(systemName: "link")
                        .primaryIcon()
                }
            }
            .padding(16)
        }
    }
}
