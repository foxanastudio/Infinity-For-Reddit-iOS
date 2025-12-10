//
//  CopyContentOptionsSheet.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-11-26.
//

import SwiftUI

struct CopyContentOptionsSheet: View {
    @Environment(\.dismiss) private var dismiss
    
    var title: String?
    let markdown: String
    let plainText: String
    
    var onCopyEntireTitle: (() -> Void)?
    var onCopyTitle: (() -> Void)?
    let onCopyEntireMarkdown: () -> Void
    let onCopyMarkdown: () -> Void
    let onCopyPlainText: () -> Void
    
    var body: some View {
        SheetRootView {
            ScrollView {
                VStack(spacing: 0) {
                    if let title, let onCopyTitle {
                        IconTextButton(startIconUrl: "document.on.document", text: "Copy Entire Title") {
                            Utils.copyText(title)
                            onCopyEntireTitle?()
                            dismiss()
                        }
                        
                        IconTextButton(startIconUrl: "document.on.document", text: "Copy Title") {
                            onCopyTitle()
                            dismiss()
                        }
                    }
                    
                    if !markdown.isEmpty {
                        IconTextButton(startIconUrl: "document.on.document", text: "Copy Entire Markdown") {
                            Utils.copyText(markdown)
                            onCopyEntireMarkdown()
                            dismiss()
                        }
                        
                        IconTextButton(startIconUrl: "document.on.document", text: "Copy Markdown") {
                            onCopyMarkdown()
                            dismiss()
                        }
                    }
                    
                    if !plainText.isEmpty {
                        IconTextButton(startIconUrl: "document.on.document", text: "Copy Plain Text") {
                            onCopyPlainText()
                            dismiss()
                        }
                    }
                }
                .padding(.top, 24)
            }
        }
    }
}
