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
import Alamofire

struct HomeView: View {
    @Environment(\.colorScheme) var colorScheme
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
        TabView(selection: $selectedTab) {
            ZStack {
                CustomNavigationStack(navigationManager: tab1NavigationManager) {
                    Color.clear
                        .onAppear {
                            if tab1NavigationManager.path.isEmpty {
                                tab1NavigationManager.append(AppNavigation.frontPage)
                            }
                        }
                }
                
                Snackbar()
                    .zIndex(1)
            }
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
                                .setUpHomeTabViewChildNavigationBar(onLogin: {
                                    accountViewModel.startLogin()
                                })
                                .addTitleToInlineNavigationBar(selectedTab.navigationTitle)
                        } else {
                            SubscriptionsView()
                                .setUpHomeTabViewChildNavigationBar(onLogin: {
                                    accountViewModel.startLogin()
                                })
                                .addTitleToInlineNavigationBar(selectedTab.navigationTitle)
                        }
                    }
                }
                
                Snackbar()
                    .zIndex(1)
            }
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
                            .setUpHomeTabViewChildNavigationBar(onLogin: {
                                accountViewModel.startLogin()
                            })
                            .addTitleToInlineNavigationBar(selectedTab.navigationTitle)
                    }
                    
                    Snackbar()
                        .zIndex(1)
                }
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
                        .setUpHomeTabViewChildNavigationBar(onLogin: {
                            accountViewModel.startLogin()
                        })
                        .addTitleToInlineNavigationBar(selectedTab.navigationTitle)
                    }
                    
                    Snackbar()
                        .zIndex(1)
                }
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
                            .setUpHomeTabViewChildNavigationBar(onLogin: {
                                accountViewModel.startLogin()
                            })
                    }
                    
                    Snackbar()
                        .zIndex(1)
                }
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
                        .setUpHomeTabViewChildNavigationBar(onLogin: {
                            accountViewModel.startLogin()
                        })
                        .addTitleToInlineNavigationBar(selectedTab.navigationTitle)
                }
                
                Snackbar()
                    .zIndex(1)
            }
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
            
            printInDebugOnly(docsDir)
            
            customThemeViewModel.setAppColorScheme(colorScheme)
            
            if accountViewModel.pendingInboxTabAfterNotificationClicked {
                selectedTab = .inbox
                accountViewModel.pendingInboxTabAfterNotificationClicked = false
            } else if let context = accountViewModel.pendingContextAfterNotificationClicked {
                currentNavigationManager.openLink(context)
                accountViewModel.pendingContextAfterNotificationClicked = nil
            }
            
            if let inboxFullname = accountViewModel.pendingInboxFullname, !inboxFullname.isEmpty {
                homeViewModel.readInbox(inboxFullname: inboxFullname)
                accountViewModel.pendingInboxFullname = nil
            }
        }
        .task {
            await homeViewModel.fetchInboxCount()
        }
        .overlay {
            if let media = fullScreenMediaViewModel.media {
                FullScreenMediaView(
                    videoFullScreenViewModel: videoFullScreenViewModel,
                    media: media
                ) {
                    fullScreenMediaViewModel.dismiss()
                }
            }
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
            let inboxFullname = note.userInfo?[AppDeepLink.fullnameKey] as? String
            
            Task {
                if !accountName.isEmpty {
                    await MainActor.run {
                        accountViewModel.inboxNavigationTarget = .init(viewMessage: viewMessage)
                    }
                    
                    if !(await accountViewModel.switchToAccountIfNeeded(accountName)) {
                        await MainActor.run {
                            selectedTab = .inbox
                        }
                        if let inboxFullname {
                            homeViewModel.readInbox(inboxFullname: inboxFullname)
                        }
                    } else {
                        await MainActor.run {
                            accountViewModel.pendingInboxTabAfterNotificationClicked = true
                            accountViewModel.pendingInboxFullname = inboxFullname
                        }
                    }
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .contextDeepLink)) { note in
            let accountName = (note.userInfo?[AppDeepLink.accountNameKey] as? String) ?? ""
            let inboxFullname = note.userInfo?[AppDeepLink.fullnameKey] as? String
            
            Task {
                if !accountName.isEmpty {
                    if !(await accountViewModel.switchToAccountIfNeeded(accountName)) {
                        if let context = (note.userInfo?[AppDeepLink.contextKey] as? String) {
                            await MainActor.run {
                                currentNavigationManager.openLink(context)
                            }
                            if let inboxFullname {
                                homeViewModel.readInbox(inboxFullname: inboxFullname)
                            }
                        }
                    } else {
                        if let context = (note.userInfo?[AppDeepLink.contextKey] as? String) {
                            await MainActor.run {
                                accountViewModel.pendingContextAfterNotificationClicked = context
                                accountViewModel.pendingInboxFullname = inboxFullname
                            }
                        }
                    }
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .appStoreEventDeepLink)) { _ in
            currentNavigationManager.append(AppNavigation.appStoreEvent)
        }
        .onReceive(NotificationCenter.default.publisher(for: .notificationToggleChanged)) { _ in
            if NotificationUserDefaultsUtils.enableNotification {
                printInDebugOnly("Foreground refresh enabled")
                homeViewModel.startInboxCountPolling()
            } else {
                printInDebugOnly("Foreground refresh disabled")
                homeViewModel.stopInboxCountPolling()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .notificationIntervalChanged)) { _ in
            homeViewModel.startInboxCountPolling()
        }
        .onReceive(accountViewModel.$error) { newValue in
            if let newValue {
                if let afError = newValue as? AFError, case .explicitlyCancelled = afError {
                    return
                } else if newValue is CancellationError {
                    return
                }
                currentSnackbarManager.showSnackbar(.error(newValue))
            } else {
                currentSnackbarManager.dismiss()
            }
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
    
    private var currentSnackbarManager: SnackbarManager {
        switch selectedTab {
        case .home:
            return tab1SnackbarManager
        case .subscriptions:
            return tab2SnackbarManager
        case .newPost:
            return tab3SnackbarManager
        case .inbox:
            return tab4SnackbarManager
        case .search:
            return tab4SnackbarManager
        case .more:
            return tab5SnackbarManager
        }
    }
}

struct FullScreenMediaView: View {
    @ObservedObject var videoFullScreenViewModel: VideoFullScreenViewModel
    
    let media: FullScreenMediaType
    let onDismiss: () -> Void
    
    var body: some View {
        switch media {
        case .image(let urlString, let aspectRatio, let post, let fileName):
            ImageFullScreenView(
                urlString: urlString,
                fileName: fileName,
                isGif: false,
                onDismiss: onDismiss
            )
        case .gallery(let currentUrlString, let post, let items, let galleryScrollState):
            GalleryFullScreenView(
                post: post,
                items: items,
                galleryScrollState: galleryScrollState,
                onDismiss: onDismiss
            )
        case .video(let urlString, let post, let videoType, let canDownload, let playbackTime):
            VideoFullScreenView(
                urlString: urlString,
                post: post,
                videoType: videoType,
                playbackTime: playbackTime,
                videoFullScreenViewModel: videoFullScreenViewModel,
                muteVideo: VideoUserDefaultsUtils.muteVideo || ((post?.over18 ?? false) && VideoUserDefaultsUtils.muteSensitiveVideo),
                canDownload: canDownload
            ) {
                onDismiss()
                videoFullScreenViewModel.resetState()
            }
        case .gif(let urlString, let post, let fileName):
            ImageFullScreenView(
                urlString: urlString,
                fileName: fileName,
                isGif: true,
                onDismiss: onDismiss
            )
        case .imgurGallery(let imgurId, let post):
            ImgurFullScreenView(
                imgurMediaType: .imgurGallery(imgurId: imgurId),
                post: post,
                onDismiss: onDismiss
            )
        case .imgurAlbum(let imgurId, let post):
            ImgurFullScreenView(
                imgurMediaType: .imgurAlbum(imgurId: imgurId),
                post: post,
                onDismiss: onDismiss
            )
        case .imgurImage(let imgurId, let post):
            ImgurFullScreenView(
                imgurMediaType: .imgurImage(imgurId: imgurId),
                post: post,
                onDismiss: onDismiss
            )
        }
    }
}
