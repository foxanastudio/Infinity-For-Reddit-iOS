//
//  MarkdownViewerSheet.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-08-25.
//

import SwiftUI
import MarkdownUI

struct MarkdownViewerSheet: View {
    @EnvironmentObject private var navigationManager: NavigationManager
    
    let markdown: String
    
    var body: some View {
        SheetRootView {
            ScrollView {
                VStack(alignment: .leading) {
                    Markdown(markdown)
                        .padding(16)
                        .themedCommentMarkdown()
                        .markdownLinkHandler { url in
                            navigationManager.openLink(url)
                        }
                    
                    Spacer()
                }
            }
        }
    }
}
