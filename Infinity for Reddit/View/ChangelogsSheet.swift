//
//  ChangelogsSheet.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2026-10-01.
//

import SwiftUI
import MarkdownUI

struct ChangelogsSheet: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        RootView {
            VStack(spacing: 0) {
                VStack(spacing: 16) {
                    RowText("What's New in \(Bundle.main.appVersion)")
                        .primaryText(.f22)
                    
                    Markdown("""
                        You can now **import and export themes**!
                        
                        **Import a Theme:**
                        
                        Go to Settings → Theme, tap the **+** button, then select **Import Theme**.
                        
                        **Export a Theme:**
                        
                        Go to Settings → Theme → Manage Theme, swipe left on a theme you created, then tap **Share**.
                        """)
                        .themedMarkdown()
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 32)
                
                Spacer()
                
                Button {
                    dismiss()
                } label: {
                    HStack {
                        Text("Continue to app")
                    }
                    .frame(maxWidth: .infinity)
                }
                .padding(16)
                .filledButton()
            }
        }
    }
}
