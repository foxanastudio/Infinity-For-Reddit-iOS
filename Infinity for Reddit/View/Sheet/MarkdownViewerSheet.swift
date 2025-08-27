//
//  MarkdownViewerSheet.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-08-25.
//

import SwiftUI
import MarkdownUI

struct MarkdownViewerSheet: View {
    let markdown: String
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                Markdown(markdown)
                    .font(.system(size: 24))
                    .padding(16)
                    .themedCommentMarkdown()
                    .markdownLinkHandler { url in
                        LinkHandler.shared.handle(url: url)
                    }
                
                Spacer()
            }
        }
    }
}
