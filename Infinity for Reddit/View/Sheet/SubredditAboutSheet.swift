//
// SubredditAboutSheet.swift
// Infinity for Reddit
//
// Created by joeylr2042 on 2025-05-06

import SwiftUI
import MarkdownUI

struct SubredditAboutSheet: View {
    @EnvironmentObject private var navigationManager: NavigationManager
    
    let subredditData: SubredditData?

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                RowText("Cakeday: \(Utils.getFormattedCakeDay(subredditData?.createdUTC))")
                    .primaryText()
                
                if let description = subredditData?.description, !description.isEmpty {
                    Markdown(description)
                        .themedMarkdown()
                        .markdownLinkHandler { url in
                            navigationManager.openLink(url)
                        }
                }
            }
            .padding(16)
        }
    }
}
