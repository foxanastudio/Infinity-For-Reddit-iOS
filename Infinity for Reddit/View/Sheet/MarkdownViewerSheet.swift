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
    let test = ">!^(~~**1**~~2)!<"
    //let test = "^(***~~strikescript~~***12)"
    //let test = "super ^(1^(2^(3^(4))))"
    //let test = "super ^1^2^3^4 haha"
    //let test = "haha >!spoiler!< >!spoiler!< >!spoiler!< >!spoiler!< >!spoiler!< >!spoiler!< >!spoiler!<"
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                //Markdown(markdown)
                Markdown(test)
                    .font(.system(size: 24))
                    .padding(16)
                    .themedCommentMarkdown()
                    .markdownLinkHandler { url in
                        navigationManager.openLink(url)
                    }
                
                Spacer()
            }
        }
        .onAppear {
            let content = MarkdownContent(test)
            print(content)
        }
    }
}
