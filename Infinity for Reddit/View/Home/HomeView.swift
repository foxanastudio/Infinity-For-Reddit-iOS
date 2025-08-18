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
    @Environment(\.scenePhase) var scenePhase
    @EnvironmentObject var accountViewModel: AccountViewModel
    @EnvironmentObject var customThemeViewModel: CustomThemeViewModel
    @EnvironmentObject var fullScreenMediaViewModel: FullScreenMediaViewModel
    @EnvironmentObject var notificationRouter: NotificationRouter
    
    @StateObject private var tab1NavigationBarMenuManager: NavigationBarMenuManager = NavigationBarMenuManager()
    @StateObject private var tab2NavigationBarMenuManager: NavigationBarMenuManager = NavigationBarMenuManager()
    @StateObject private var tab3NavigationBarMenuManager: NavigationBarMenuManager = NavigationBarMenuManager()
    @StateObject private var tab4NavigationBarMenuManager: NavigationBarMenuManager = NavigationBarMenuManager()
    @StateObject private var tab5NavigationBarMenuManager: NavigationBarMenuManager = NavigationBarMenuManager()
    
    @StateObject private var homeViewModel = HomeViewModel()
    
    @State private var selectedTab: Tab = .home
    @State private var showProfile: Bool = false
    @State private var timerIsActive = true
    
    let timer = Timer.publish(every: 15 * 60, on: .main, in: .common).autoconnect()
    
    @Namespace private var animation
    
    var body: some View {
        ZStack {
            TabView(selection: $selectedTab) {
                Group {
                    CustomNavigationStack {
                        PostListingView(
                            account: accountViewModel.account,
                            postListingMetadata: PostListingMetadata(
                                // Anonymous subscriptions will be fetched later in PostListingViewModel
                                postListingType: accountViewModel.account.isAnonymous() ? .anonymousFrontPage(concatenatedSubscriptions: nil) : .frontPage,
                                headers: APIUtils.getOAuthHeader(accessToken: accountViewModel.account.accessToken ?? ""),
                                queries: nil,
                                params: nil
                            ),
                            handleToolbarMenu: false
                        )
                        .setUpHomeTabViewChildNavigationBar()
                        .addTitleToInlineNavigationBar(selectedTab.navigationTitle)
                    }
                    .id(accountViewModel.account.username)
                    .tabItem {
                        Label("Home", systemImage: "house")
                    }
                    .tag(Tab.home)
                    .environmentObject(tab1NavigationBarMenuManager)
                    
                    CustomNavigationStack {
                        Group {
                            if accountViewModel.account.isAnonymous() {
                                AnonymousSubscriptionsView()
                                    .setUpHomeTabViewChildNavigationBar()
                                    .addTitleToInlineNavigationBar(selectedTab.navigationTitle)
                            } else {
                                SubscriptionsView()
                                    .setUpHomeTabViewChildNavigationBar()
                                    .addTitleToInlineNavigationBar(selectedTab.navigationTitle)
                            }
                        }
                    }
                    .id(accountViewModel.account.username)
                    .tabItem {
                        Label("Subscriptions", systemImage: "book")
                    }
                    .tag(Tab.subscriptions)
                    .environmentObject(tab2NavigationBarMenuManager)
                    
                    if !accountViewModel.account.isAnonymous() {
                        CustomNavigationStack {
                            InboxView(
                                account: accountViewModel.account
                            )
                            .setUpHomeTabViewChildNavigationBar()
                            .addTitleToInlineNavigationBar(selectedTab.navigationTitle)
                        }
                        .id(accountViewModel.account.username)
                        .tabItem {
                            Label("Inbox", systemImage: "envelope")
                        }
                        .tag(Tab.inbox)
                        .badge(homeViewModel.hasNewMessages ? "!" : nil)
                        .environmentObject(tab3NavigationBarMenuManager)
                    }
                    
                    CustomNavigationStack {
                        SearchView(username: accountViewModel.account.username)
                            .setUpHomeTabViewChildNavigationBar()
                            .addTitleToInlineNavigationBar(selectedTab.navigationTitle)
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
                            .addTitleToInlineNavigationBar(selectedTab.navigationTitle)
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
            .onChange(of: selectedTab) { _, newTab in
                print("Tab selection changed to: \(newTab)")
                
                if newTab == .inbox {
                    homeViewModel.userViewedInbox()
                }
            }
            
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
        .onChange(of: accountViewModel.account) { oldValue, newValue in
            if newValue.isAnonymous(), case .inbox = selectedTab {
                selectedTab = .home
            }
        }
        .environmentObject(NamespaceManager(animation))
        .task {
//            try? await Task.sleep(nanoseconds: 3 * 1_000_000_000)
            await homeViewModel.refreshInbox()
        }
        .onReceive(timer) { _ in
            guard timerIsActive else { return }
            Task {
                await homeViewModel.refreshInbox()
            }
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                timerIsActive = true
            } else {
                timerIsActive = false
            }
        }
        .onChange(of: notificationRouter.route) { _, newRoute in
            guard let route = newRoute else { return }
            switch route.kind {
            case let .openInbox(account, viewMessage, fullname):
                selectedTab = .inbox
                NotificationCenter.default.post(name: .inboxDeepLink, object: nil, userInfo: [
                    "accountName": account,
                    "viewMessage": viewMessage,
                    "messageFullname": fullname as Any
                ])
            }
            
            notificationRouter.route = nil
        }
        .task {
            if let route = notificationRouter.route {
                switch route.kind {
                case let .openInbox(account, viewMessage, fullname):
                    selectedTab = .inbox
                    NotificationCenter.default.post(name: .inboxDeepLink, object: nil, userInfo: [
                        "accountName": account,
                        "viewMessage": viewMessage,
                        "messageFullname": fullname as Any
                    ])
                }
                notificationRouter.route = nil
            }
        }
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
