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
                        Fixed an issue where videos started at an incorrect time in fullscreen mode.
                        """)
                        .themedMarkdown()
                }
                .padding(.horizontal, 32)
                .padding(.top, 32)
                
                Spacer()
                
                Button {
                    dismiss()
                } label: {
                    HStack {
                        Text("Continue to app")
                    }
                    .frame(maxWidth: .infinity)
                }
                .padding(.horizontal, 32)
                .padding(.top, 32)
                .padding(.bottom, 16)
                .filledButton()
            }
        }
    }
}
