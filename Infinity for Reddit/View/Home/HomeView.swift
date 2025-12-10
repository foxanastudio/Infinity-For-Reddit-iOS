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
import SwiftUIIntrospect

struct HomeView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dependencyManager) private var dependencyManager: Container
    @Environment(\.scenePhase) var scenePhase
    @EnvironmentObject var accountViewModel: AccountViewModel
    @EnvironmentObject var customThemeViewModel: CustomThemeViewModel
    
    @ObservedObject var fullScreenMediaViewModel: FullScreenMediaViewModel
    
    @StateObject private var tab1NavigationManager: NavigationManager
    @StateObject private var tab2NavigationManager: NavigationManager
    @StateObject private var tab3NavigationManager: NavigationManager
    @StateObject private var tab4NavigationManager: NavigationManager
    @StateObject private var tab5NavigationManager: NavigationManager
    
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
    
    @StateObject private var homeViewModel = HomeViewModel(homeRepository: HomeRepository())
    
    @StateObject private var videoFullScreenViewModel = VideoFullScreenViewModel()
    
    @State private var selectedTab: Tab = .home
    @State private var showProfile: Bool = false
    
    @Namespace private var animation
    
    init(fullScreenMediaViewModel: FullScreenMediaViewModel) {
        self.fullScreenMediaViewModel = fullScreenMediaViewModel
        _tab1NavigationManager = StateObject(wrappedValue: NavigationManager(fullScreenMediaViewModel: fullScreenMediaViewModel,
                                                                             firstViewShouldHideNavigationBarOnScrollDown: true))
        _tab2NavigationManager = StateObject(wrappedValue: NavigationManager(fullScreenMediaViewModel: fullScreenMediaViewModel,
                                                                             firstViewShouldHideNavigationBarOnScrollDown: false))
        _tab3NavigationManager = StateObject(wrappedValue: NavigationManager(fullScreenMediaViewModel: fullScreenMediaViewModel,
                                                                             firstViewShouldHideNavigationBarOnScrollDown: false))
        _tab4NavigationManager = StateObject(wrappedValue: NavigationManager(fullScreenMediaViewModel: fullScreenMediaViewModel,
                                                                             firstViewShouldHideNavigationBarOnScrollDown: false))
        _tab5NavigationManager = StateObject(wrappedValue: NavigationManager(fullScreenMediaViewModel: fullScreenMediaViewModel,
                                                                             firstViewShouldHideNavigationBarOnScrollDown: false))
    }
    
    var body: some View {
        ZStack {
            TabView(selection: $selectedTab) {
                ZStack {
                    CustomNavigationStack(navigationManager: tab1NavigationManager) {
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
                .onChange(of: tab1NavigationManager.path) {
                    tab1SnackbarManager.dismissIfIndefinite()
                }
                
                ZStack {
                    CustomNavigationStack(navigationManager: tab2NavigationManager) {
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
                .onChange(of: tab2NavigationManager.path) {
                    tab2SnackbarManager.dismissIfIndefinite()
                }
                
                if !accountViewModel.account.isAnonymous() {
                    ZStack {
                        CustomNavigationStack(navigationManager: tab3NavigationManager) {
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
                    .onChange(of: tab3NavigationManager.path) {
                        tab3SnackbarManager.dismissIfIndefinite()
                    }
                    
                    ZStack {
                        CustomNavigationStack(navigationManager: tab4NavigationManager) {
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
                    .badge(homeViewModel.inboxCount > 0 ? String(homeViewModel.inboxCount) : nil)
                    .environmentObject(tab4NavigationBarMenuManager)
                    .environmentObject(homeViewModel)
                    .environmentObject(tab4SnackbarManager)
                    .onChange(of: tab4NavigationManager.path) {
                        tab4SnackbarManager.dismissIfIndefinite()
                    }
                } else {
                    ZStack {
                        CustomNavigationStack(navigationManager: tab4NavigationManager) {
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
                    .onChange(of: tab4NavigationManager.path) {
                        tab4SnackbarManager.dismissIfIndefinite()
                    }
                }
                
                ZStack {
                    CustomNavigationStack(navigationManager: tab5NavigationManager) {
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
                .onChange(of: tab5NavigationManager.path) {
                    tab5SnackbarManager.dismissIfIndefinite()
                }
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
                if case let .image(urlString, aspectRatio, post, fileName, matchedGeometryEffectId) = media {
                    ImageFullScreenView(urlString: urlString, fileName: fileName, matchedGeometryEffectId: matchedGeometryEffectId, isGif: false) {
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
                } else if case let .gif(urlString, post, fileName) = media {
                    ImageFullScreenView(urlString: urlString, fileName: fileName, isGif: true) {
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
        .task {
            await homeViewModel.fetchInboxCount()
        }
        .onChange(of: colorScheme) { _, newValue in
            if scenePhase != .background {
                customThemeViewModel.setAppColorScheme(newValue)
            }
        }
        .onChange(of: accountViewModel.account) { oldValue, newValue in
            if newValue.isAnonymous(), case .inbox = selectedTab {
                selectedTab = .home
            }
            
            homeViewModel.startInboxCountPolling(resetPollingTime: true)
        }
        .environmentObject(NamespaceManager(animation))
        .appForegroundBackgroundListener(onAppEntersForeground: {
            if NotificationUserDefaultsUtils.enableNotification {
                homeViewModel.startInboxCountPolling()
            }
        }, onAppEntersBackground: {
            homeViewModel.stopInboxCountPolling()
        })
        .onReceive(NotificationCenter.default.publisher(for: .inboxDeepLink)) { note in
            let accountName = (note.userInfo?[AppDeepLink.accountNameKey] as? String) ?? ""
            let viewMessage = (note.userInfo?[AppDeepLink.viewMessageKey] as? Bool) ?? false
            
            Task {
                if !accountName.isEmpty {
                    await accountViewModel.switchToAccountIfNeeded(accountName)
                }
                
                await MainActor.run {
                    homeViewModel.inboxNavigationTarget = .init(viewMessage: viewMessage)
                    selectedTab = .inbox
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .contextDeepLink)) { note in
            let accountName = (note.userInfo?[AppDeepLink.accountNameKey] as? String) ?? ""
            
            Task {
                if !accountName.isEmpty {
                    await accountViewModel.switchToAccountIfNeeded(accountName)
                }
                
                if let context = (note.userInfo?[AppDeepLink.contextKey] as? String) {
                    await MainActor.run {
                        currentNavigationManager.openLink(context)
                    }
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .notificationToggleChanged)) { _ in
            if NotificationUserDefaultsUtils.enableNotification {
                print("Foreground refresh enabled")
                homeViewModel.startInboxCountPolling()
            } else {
                print("Foreground refresh disabled")
                homeViewModel.stopInboxCountPolling()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .notificationIntervalChanged)) { _ in
            homeViewModel.startInboxCountPolling()
        }
    }
    
    enum Tab {
        case home, subscriptions, inbox, newPost, search, more
        
        var navigationTitle: String {
            switch self {
            case .home:
                return "Home"
            case .subscriptions:
                return "Subscriptions"
            case .newPost:
                return "New Post"
            case .inbox:
                return "Inbox"
            case .search:
                return "Search"
            case .more:
                return "More"
            }
        }
    }
    
    private var currentNavigationManager: NavigationManager {
        switch selectedTab {
        case .home:
            return tab1NavigationManager
        case .subscriptions:
            return tab2NavigationManager
        case .newPost:
            return tab3NavigationManager
        case .inbox:
            return tab4NavigationManager
        case .search:
            return tab4NavigationManager
        case .more:
            return tab5NavigationManager
        }
    }
}
