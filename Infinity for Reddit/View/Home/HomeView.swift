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
    
    @StateObject private var tab1NavigationBarMenuManager: NavigationBarMenuManager = NavigationBarMenuManager()
    @StateObject private var tab2NavigationBarMenuManager: NavigationBarMenuManager = NavigationBarMenuManager()
    @StateObject private var tab3NavigationBarMenuManager: NavigationBarMenuManager = NavigationBarMenuManager()
    @StateObject private var tab4NavigationBarMenuManager: NavigationBarMenuManager = NavigationBarMenuManager()
    @StateObject private var tab5NavigationBarMenuManager: NavigationBarMenuManager = NavigationBarMenuManager()
    
    @StateObject private var tab1SnackbarManager: SnackbarManager = SnackbarManager()
    @StateObject private var tab2SnackbarManager: SnackbarManager = SnackbarManager()
    @StateObject private var tab3SnackbarManager: SnackbarManager = SnackbarManager()
    @StateObject private var tab4SnackbarManager: SnackbarManager = SnackbarManager()
    @StateObject private var tab5SnackbarManager: SnackbarManager = SnackbarManager()
    
    @StateObject private var homeViewModel = HomeViewModel()
    
    @StateObject private var videoFullScreenViewModel = VideoFullScreenViewModel()
    
    @State private var selectedTab: Tab = .home
    @State private var showProfile: Bool = false
    
    @Namespace private var animation
    
    var body: some View {
        ZStack {
            TabView(selection: $selectedTab) {
                Group {
                    ZStack {
                        CustomNavigationStack(fullScreenMediaViewModel: fullScreenMediaViewModel) {
                            PostListingView(
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
                        
                        Snackbar()
                            .zIndex(1)
                    }
                    .id(accountViewModel.account.username)
                    .tabItem {
                        Label("Home", systemImage: "house")
                    }
                    .tag(Tab.home)
                    .environmentObject(tab1NavigationBarMenuManager)
                    .environmentObject(tab1SnackbarManager)
                    
                    ZStack {
                        CustomNavigationStack(fullScreenMediaViewModel: fullScreenMediaViewModel) {
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
                        
                        Snackbar()
                            .zIndex(1)
                    }
                    .id(accountViewModel.account.username)
                    .tabItem {
                        Label("Subscriptions", systemImage: "book")
                    }
                    .tag(Tab.subscriptions)
                    .environmentObject(tab2NavigationBarMenuManager)
                    .environmentObject(tab2SnackbarManager)
                    
                    if !accountViewModel.account.isAnonymous() {
                        ZStack {
                            CustomNavigationStack(fullScreenMediaViewModel: fullScreenMediaViewModel) {
                                NewPostTypeChooserView()
                                    .setUpHomeTabViewChildNavigationBar()
                                    .addTitleToInlineNavigationBar(selectedTab.navigationTitle)
                            }
                            
                            Snackbar()
                                .zIndex(1)
                        }
                        .id(accountViewModel.account.username)
                        .tabItem {
                            Label("New Post", systemImage: "plus.circle")
                        }
                        .tag(Tab.newPost)
                        .environmentObject(tab3NavigationBarMenuManager)
                        .environmentObject(homeViewModel)
                        .environmentObject(tab3SnackbarManager)
                        
                        ZStack {
                            CustomNavigationStack(fullScreenMediaViewModel: fullScreenMediaViewModel) {
                                InboxView(
                                    account: accountViewModel.account
                                )
                                .setUpHomeTabViewChildNavigationBar()
                                .addTitleToInlineNavigationBar(selectedTab.navigationTitle)
                            }
                            
                            Snackbar()
                                .zIndex(1)
                        }
                        .id(accountViewModel.account.username)
                        .tabItem {
                            Label("Inbox", systemImage: "envelope")
                        }
                        .tag(Tab.inbox)
                        .badge(homeViewModel.hasNewMessages ? "!" : nil)
                        .environmentObject(tab4NavigationBarMenuManager)
                        .environmentObject(homeViewModel)
                        .environmentObject(tab4SnackbarManager)
                    } else {
                        ZStack {
                            CustomNavigationStack(fullScreenMediaViewModel: fullScreenMediaViewModel) {
                                SearchView()
                                    .setUpHomeTabViewChildNavigationBar()
                                    .addTitleToInlineNavigationBar(selectedTab.navigationTitle)
                            }
                            
                            Snackbar()
                                .zIndex(1)
                        }
                        .id(accountViewModel.account.username)
                        .tabItem {
                            Label("Search", systemImage: "magnifyingglass")
                        }
                        .tag(Tab.search)
                        .environmentObject(tab4NavigationBarMenuManager)
                        .environmentObject(tab4SnackbarManager)
                    }
                    
                    ZStack {
                        CustomNavigationStack(fullScreenMediaViewModel: fullScreenMediaViewModel) {
                            MoreView()
                                .setUpHomeTabViewChildNavigationBar()
                                .addTitleToInlineNavigationBar(selectedTab.navigationTitle)
                        }
                        
                        Snackbar()
                            .zIndex(1)
                    }
                    .id(accountViewModel.account.username)
                    .tabItem {
                        Label("More", systemImage: "ellipsis.circle.fill")
                    }
                    .tag(Tab.more)
                    .environmentObject(tab5NavigationBarMenuManager)
                    .environmentObject(tab5SnackbarManager)
                }
                .themedTabViewGroup()
            }
            .themedTabView()
            .onAppear {
                let dirPaths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
                let docsDir = dirPaths[0]
                
                print(docsDir)
                
                customThemeViewModel.setAppColorScheme(colorScheme)
            }
            .id(accountViewModel.account.username)
            
            if let media = fullScreenMediaViewModel.media {
                if case let .image(urlString, aspectRatio, post, matchedGeometryEffectId) = media {
                    ImageFullScreenView(urlString: urlString, matchedGeometryEffectId: matchedGeometryEffectId) {
                        fullScreenMediaViewModel.dismiss()
                    }
                    .id(urlString)
                    .zIndex(1)
                } else if case let .gallery(currentUrlString, post, items, galleryScrollState) = media {
                    GalleryFullScreenView(post: post, items: items, galleryScrollState: galleryScrollState) {
                        fullScreenMediaViewModel.dismiss()
                    }
                    .id(currentUrlString)
                } else if case let .video(urlString, post, videoType) = media {
                    VideoFullScreenView(urlString: urlString, post: post, videoType: videoType, videoFullScreenViewModel: videoFullScreenViewModel) {
                        fullScreenMediaViewModel.dismiss()
                        videoFullScreenViewModel.resetState()
                    }
                    .id(urlString)
                    .zIndex(1)
                } else if case let .gif(urlString, post) = media {
                    ImageFullScreenView(urlString: urlString) {
                        fullScreenMediaViewModel.dismiss()
                    }
                    .id(urlString)
                    .zIndex(1)
                } else if case let .imgurAlbum(imgurId, post) = media {
                    ImgurFullScreenView(imgurMediaType: .imgurAlbum(imgurId: imgurId), post: post) {
                        fullScreenMediaViewModel.dismiss()
                    }
                    .id(imgurId)
                    .zIndex(1)
                } else if case let .imgurGallery(imgurId, post) = media {
                    ImgurFullScreenView(imgurMediaType: .imgurGallery(imgurId: imgurId), post: post) {
                        fullScreenMediaViewModel.dismiss()
                    }
                    .id(imgurId)
                    .zIndex(1)
                } else if case let .imgurImage(imgurId, post) = media {
                    ImgurFullScreenView(imgurMediaType: .imgurImage(imgurId: imgurId), post: post) {
                        fullScreenMediaViewModel.dismiss()
                    }
                    .id(imgurId)
                    .zIndex(1)
                }
            }
        }
        .onChange(of: colorScheme) {
            customThemeViewModel.setAppColorScheme(colorScheme)
        }
        .onChange(of: accountViewModel.account) { oldValue, newValue in
            if newValue.isAnonymous(), case .inbox = selectedTab {
                selectedTab = .home
            }
        }
        .environmentObject(NamespaceManager(animation))
        .onChange(of: scenePhase) { _, newPhase in
            if NotificationUserDefaultsUtils.enableNotification {
                if newPhase == .active {
                    homeViewModel.startAutoRefresh()
                } else {
                    homeViewModel.stopAutoRefresh()
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .inboxDeepLink)) { note in
            let accountName = (note.userInfo?["accountName"] as? String) ?? ""
            let viewMessage = (note.userInfo?["viewMessage"] as? Bool) ?? false
            
            Task { @MainActor in
                if !accountName.isEmpty {
                    await accountViewModel.switchToAccountIfNeeded(accountName)
                }
                selectedTab = .inbox
                Task { @MainActor in
                    homeViewModel.inboxNavigationTarget = .init(viewMessage: viewMessage)
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .notificationToggleChanged)) { note in
            let enabled = (note.userInfo?["enabled"] as? Bool) ?? false
            if enabled {
                print("Foreground refresh enabled")
                homeViewModel.startAutoRefresh()
            } else {
                print("Foreground refresh disabled")
                homeViewModel.stopAutoRefresh()
            }
        }
    }
    
    enum Tab {
        case home, subscriptions, inbox, newPost, search, more
        
        var navigationTitle: String {
            switch self {
            case .home: return "Home"
            case .subscriptions: return "Subscriptions"
            case .newPost: return "New Post"
            case .inbox: return "Inbox"
            case .search: return "Search"
            case .more: return "More"
            }
        }
    }
}
