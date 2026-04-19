//
//  GalleryOrImgurDescriptionSheet.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-10-08.
//

import SwiftUI
import MarkdownUI

struct GalleryOrImgurDescriptionSheet: View {
    let title: String?
    let description: String
    let link: String?
    
    var body: some View {
        SheetRootView {
            ScrollView {
                VStack(spacing: 16) {
                    if let title, !title.isEmpty {
                        RowText(title)
                            .primaryText(.f24)
                            .fontWeight(.bold)
                    }
                    
                    if !description.isEmpty {
                        DescriptionOrLinkMarkdown(content: description)
                    }
                    
                    if let link, !link.isEmpty {
                        DescriptionOrLinkMarkdown(content: link)
                    }
                }
                .padding(16)
            }
        }
    }
}

private struct DescriptionOrLinkMarkdown: View {
    @EnvironmentObject private var customThemeViewModel: CustomThemeViewModel
    
    let content: String
    
    var body: some View {
        Markdown(content)
            .themedMarkdown()
            .markdownLinkHandler { url in
                UIApplication.shared.open(url)
            }
    }
}
