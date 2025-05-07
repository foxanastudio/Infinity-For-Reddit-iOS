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
    
    @State private var selectedTab: Tab = .home
    @State private var showProfile: Bool = false
    @StateObject private var navigationManager = NavigationManager()
    
    @Namespace private var animation
    
    var body: some View {
        ZStack {
            NavigationStack(path: $navigationManager.path) {
                TabView(selection: $selectedTab) {
                    Group {
                        PostListingView(
                            account: accountViewModel.account,
                            postListingMetadata: PostListingMetadata(
                                postListingType: .frontPage,
                                pathComponents: ["sortType": "best"],
                                headers: APIUtils.getOAuthHeader(accessToken: accountViewModel.account.accessToken ?? ""),
                                queries: nil,
                                params: nil
                            )
                        )
                        .id(accountViewModel.account.username)
                        .tabItem {
                            Label("Home", systemImage: "house")
                        }
                        .tag(Tab.home)
                        
                        SubscriptionsView()
                            .id(accountViewModel.account.username)
                            .tabItem {
                                Label("Subscriptions", systemImage: "book")
                            }
                            .tag(Tab.subscriptions)
                        
                        CommentListingView(
                            commentListingMetadata: CommentListingMetadata(
                                commentListingType: .user,
                                pathComponents: ["sortType": "best"],
                                headers: APIUtils.getOAuthHeader(accessToken: accountViewModel.account.accessToken ?? ""),
                                queries: nil,
                                params: nil
                            )
                        )
                        .id(accountViewModel.account.username)
                        .tabItem {
                            Label("Inbox", systemImage: "envelope")
                        }
                        .tag(Tab.inbox)
                        
                        MoreView()
                            .id(accountViewModel.account.username)
                            .tabItem {
                                Label("More", systemImage: "person")
                            }
                            .tag(Tab.more)
                    }
                    .themedTabViewGroup()
                }
                .themedTabView()
                .toolbar {
                    if let leadingButton = selectedTab.leadingButton {
                        ToolbarItem(placement: .navigationBarLeading) {
                            leadingButton
                                .navigationBarButton()
                        }
                    }
                    
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            showProfile.toggle()
                        }) {
                            CustomWebImage(
                                accountViewModel.account.profileImageUrl,
                                width: 30,
                                height: 30,
                                circleClipped: true,
                                handleImageTapGesture: false,
                                fallbackView: {
                                    SwiftUI.Image(systemName: "person.crop.circle")
                                        .resizable()
                                        .frame(width: 30, height: 30)
                                        .navigationBarImage()
                                }
                            )
                        }
                    }
                }
                .themedNavigationBar()
                .addTitleToInlineNavigationBar(selectedTab.navigationTitle)
                .sheet(isPresented: $showProfile) {
                    AccountSheet()
                        .presentationDetents([.height(800)])
                }
                .onAppear {
                    let dirPaths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
                    let docsDir = dirPaths[0]
                    
                    print(docsDir)
                }
                .navigationDestination(for: AppNavigation.self) { destination in
                    if case .postDetails(let post) = destination {
                        PostDetailsView(account: accountViewModel.account, post: post)
                    } else if case .userDetails(let username) = destination {
                        UserDetailsView(username: username)
                    } else if case .subredditDetails(let subredditName) = destination {
                        SubredditDetailsView(subredditName: subredditName)
                    }
                }
                .navigationDestination(for: MoreViewNavigation.self) { destination in
                    switch destination {
                    case .profile:
                        ProfileView()
                    case .history:
                        HistoryView()
                    case .upvoted:
                        UpvotedView()
                    case .downvoted:
                        DownvotedView()
                    case .hidden:
                        HiddenView()
                    case .saved:
                        SavedView()
                    case .settings:
                        SettingsView()
                    case .test:
                        TestView()
                    }
                }
            }
            .themedNavigationBarBackButton()
            
            if let media = fullScreenMediaViewModel.media {
                if case let .image(urlString, aspectRatio, post) = media {
                    ImageFullScreenView(url: URL(string: urlString), aspectRatio: aspectRatio) {
                        fullScreenMediaViewModel.dismiss()
                    }
                    .id(UUID())
                } else if case let .gallery(items, mediaMetadata) = media {
                    GalleryFullScreenView(items: items, mediaMetadata: mediaMetadata) {
                        fullScreenMediaViewModel.dismiss()
                    }
                    .id(UUID())
                } else if case let .video(videoUrl, post) = media {
                    VideoFullScreenView()
                    .id(UUID())
                }
            }
        }
        .onChange(of: colorScheme) {
            customThemeViewModel.isDarkTheme = colorScheme == .dark
        }
        .environmentObject(navigationManager)
        .environmentObject(NamespaceManager(animation))
    }
    
    enum Tab {
        case home, subscriptions, inbox, more
        
        var navigationTitle: String {
            switch self {
            case .home: return "Home"
            case .subscriptions: return "Subscriptions"
            case .inbox: return "Inbox"
            case .more: return "More"
            }
        }
        
        var leadingButton: AnyView? {
            switch self {
            case .home: return AnyView(Button(action: { print("Leading Action") }) { Text("Edit") })
            default: return nil
            }
        }
        
        var trailingButton: AnyView? {
            switch self {
            case .home: return AnyView(Button(action: { print("Search Home") }) { SwiftUI.Image(systemName: "magnifyingglass") })
            case .subscriptions: return AnyView(Button(action: { print("Manage Subscriptions") }) { Text("Manage") })
            default: return nil
            }
        }
    }
}
