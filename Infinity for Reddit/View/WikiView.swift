//
//  WikiView.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-11-25.
//

import SwiftUI
import MarkdownUI

struct WikiView: View {
    @EnvironmentObject private var navigationManager: NavigationManager
    
    @StateObject var wikiViewModel: WikiViewModel
    
    init(subredditName: String, wikiPath: String) {
        _wikiViewModel = StateObject(wrappedValue: WikiViewModel(
            subedditName: subredditName,
            wikiPath: wikiPath,
            wikiRepository: WikiRepository()
        ))
    }
    
    var body: some View {
        RootView {
            ZStack {
                if let wiki = wikiViewModel.wiki {
                    ScrollView {
                        if wiki.isEmpty {
                            Text("No wiki found")
                                .primaryText()
                                .padding(16)
                        } else {
                            Markdown(wiki)
                                .themedMarkdown()
                                .padding(16)
                                .markdownLinkHandler { url in
                                    navigationManager.openLink(url)
                                }
                        }
                    }
                } else {
                    if let error = wikiViewModel.error {
                        ZStack {
                            Text("Failed to load wiki: \(error.localizedDescription). Tap to retry")
                                .primaryText()
                                .padding(16)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .onTapGesture {
                            wikiViewModel.wikiTaskTrigger.toggle()
                        }
                    } else {
                        ProgressIndicator()
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .themedNavigationBar()
        .addTitleToInlineNavigationBar("Wiki")
        .task(id: wikiViewModel.wikiTaskTrigger) {
            await wikiViewModel.fetchWiki()
        }
    }
}
