//
// SubredditAboutView.swift
// Infinity for Reddit
//
// Created by joeylr2042 on 2025-05-06

import SwiftUI
import MarkdownUI

struct SubredditAboutView: View {
    @EnvironmentObject private var navigationManager: NavigationManager
    
    let subredditData: SubredditData?

    var body: some View {
        ScrollView {
            if let description = subredditData?.description, !description.isEmpty {
                Markdown(description)
                    .themedMarkdown()
                    .padding(0)
                    .markdownLinkHandler { url in
                        navigationManager.openLink(url)
                    }
            }
        }
    }
}
