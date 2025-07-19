//
//  ContentView.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2024-11-27.
//

import SwiftUI
import Swinject
import GRDB
import SDWebImageSwiftUI

struct HomeView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dependencyManager) private var dependencyManager: Container
    @EnvironmentObject var accountViewModel: AccountViewModel
    @EnvironmentObject var customThemeViewModel: CustomThemeViewModel
    @EnvironmentObject var fullScreenMediaViewModel: FullScreenMediaViewModel
    
    @StateObject private var tab1NavigationBarMenuManager: NavigationBarMenuManager = NavigationBarMenuManager()
    @StateObject private var tab2NavigationBarMenuManager: NavigationBarMenuManager = NavigationBarMenuManager()
    @StateObject private var tab3NavigationBarMenuManager: NavigationBarMenuManager = NavigationBarMenuManager()
    @StateObject private var tab4NavigationBarMenuManager: NavigationBarMenuManager = NavigationBarMenuManager()
    @StateObject private var tab5NavigationBarMenuManager: NavigationBarMenuManager = NavigationBarMenuManager()
    
    @State private var selectedTab: Tab = .home
    @State private var showProfile: Bool = false
    
    @Namespace private var animation
    
    var body: some View {
        ZStack {
            TabView(selection: $selectedTab) {
                Group {
                    CustomNavigationStack {
                        PostListingTestView(
                            account: accountViewModel.account,
                            postListingMetadata: PostListingMetadata(
                                postListingType: .frontPage,
                                headers: APIUtils.getOAuthHeader(accessToken: accountViewModel.account.accessToken ?? ""),
                                queries: nil,
                                params: nil
                            ),
                            handleToolbarMenu: false
                        )
                        .setUpHomeTabViewChildNavigationBar()
                        .addTitleToInlineNavigationBar(selectedTab.navigationTitle, 1.0)
                    }
                    .id(accountViewModel.account.username)
                    .tabItem {
                        Label("Home", systemImage: "house")
                    }
                    .tag(Tab.home)
                    .environmentObject(tab1NavigationBarMenuManager)
                    
                    CustomNavigationStack {
                        SubscriptionsView()
                            .setUpHomeTabViewChildNavigationBar()
                            .addTitleToInlineNavigationBar(selectedTab.navigationTitle, 1.0)
                    }
                    .id(accountViewModel.account.username)
                    .tabItem {
                        Label("Subscriptions", systemImage: "book")
                    }
                    .tag(Tab.subscriptions)
                    .environmentObject(tab2NavigationBarMenuManager)
                    
                    CustomNavigationStack {
                        InboxView(
                            account: accountViewModel.account
                        )
                        .setUpHomeTabViewChildNavigationBar()
                        .addTitleToInlineNavigationBar(selectedTab.navigationTitle, 1.0)
                    }
                    .id(accountViewModel.account.username)
                    .tabItem {
                        Label("Inbox", systemImage: "envelope")
                    }
                    .tag(Tab.inbox)
                    .environmentObject(tab3NavigationBarMenuManager)
                    
                    CustomNavigationStack {
                        SearchView(username: accountViewModel.account.username)
                            .setUpHomeTabViewChildNavigationBar()
                            .addTitleToInlineNavigationBar(selectedTab.navigationTitle, 1.0)
                    }
                    .id(accountViewModel.account.username)
                    .tabItem {
                        Label("Search", systemImage: "magnifyingglass")
                    }
                    .tag(Tab.search)
                    .environmentObject(tab4NavigationBarMenuManager)
                    
                    CustomNavigationStack {
                        MoreView()
                            .setUpHomeTabViewChildNavigationBar()
                            .addTitleToInlineNavigationBar(selectedTab.navigationTitle, 1.0)
                    }
                    .id(accountViewModel.account.username)
                    .tabItem {
                        Label("More", systemImage: "person")
                    }
                    .tag(Tab.more)
                    .environmentObject(tab5NavigationBarMenuManager)
                }
                .themedTabViewGroup()
            }
            .themedTabView()
            .onAppear {
                let dirPaths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
                let docsDir = dirPaths[0]
                
                print(docsDir)
            }
            .id(accountViewModel.account.username)
            
            if let media = fullScreenMediaViewModel.media {
                if case let .image(urlString, aspectRatio, post, matchedGeometryEffectId) = media {
                    ImageFullScreenView(url: URL(string: urlString), aspectRatio: aspectRatio, matchedGeometryEffectId: matchedGeometryEffectId) {
                        fullScreenMediaViewModel.dismiss()
                    }
                    .id(UUID())
                } else if case let .gallery(currentUrl, items, mediaMetadata, galleryScrollState) = media {
                    GalleryFullScreenView(items: items, mediaMetadata: mediaMetadata, galleryScrollState: galleryScrollState) {
                        fullScreenMediaViewModel.dismiss()
                    }
                    .id(UUID())
                } else if case let .video(videoUrl, post) = media {
                    if let url = URL(string: videoUrl) {
                        VideoFullScreenView(url: url) {
                            fullScreenMediaViewModel.dismiss()
                        }
                        .id(UUID())
                    }
                }
            }
        }
        .onChange(of: colorScheme) {
            customThemeViewModel.isDarkTheme = colorScheme == .dark
        }
        .environmentObject(NamespaceManager(animation))
    }
    
    enum Tab {
        case home, subscriptions, inbox, search, more
        
        var navigationTitle: String {
            switch self {
            case .home: return "Home"
            case .subscriptions: return "Subscriptions"
            case .inbox: return "Inbox"
            case .search: return "Search"
            case .more: return "More"
            }
        }
    }
}
