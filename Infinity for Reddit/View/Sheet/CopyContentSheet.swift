//
//  CopyContentSheet.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-11-26.
//

import SwiftUI

struct CopyContentSheet: View {
    @Environment(\.dismiss) private var dismiss
    
    let markdown: String
    let plainText: String
    
    let onCopyMarkdown: () -> Void
    let onCopyPlainText: () -> Void
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                IconTextButton(startIconUrl: "document.on.document", text: "Copy All Markdown") {
                    Utils.copyText(markdown)
                    dismiss()
                }
                
                IconTextButton(startIconUrl: "document.on.document", text: "Copy Markdown") {
                    onCopyMarkdown()
                    dismiss()
                }
                
                IconTextButton(startIconUrl: "document.on.document", text: "Copy All Plain Text") {
                    Utils.copyText(plainText)
                    dismiss()
                }
                
                IconTextButton(startIconUrl: "document.on.document", text: "Copy Plain Text") {
                    onCopyPlainText()
                    dismiss()
                }
            }
            .padding(.top, 24)
        }
    }
}
