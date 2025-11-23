//
//  UserDetailsView.swift
//  Infinity for Reddit
//
//  Created by joeylr2042 on 2025-02-08.
//

import SwiftUI
import SDWebImageSwiftUI
import MarkdownUI

struct UserDetailsView: View {
    @EnvironmentObject var accountViewModel: AccountViewModel
    @EnvironmentObject private var navigationManager: NavigationManager
    @EnvironmentObject var themeViewModel: CustomThemeViewModel
    @EnvironmentObject var navigationBarMenuManager: NavigationBarMenuManager
    
    @StateObject var userDetailsViewModel : UserDetailsViewModel
    
    @State private var navigationBarMenuKey: UUID?
    @State private var tabBarVisibility: Visibility = .hidden
    @State private var selectedTab = 0
    @State private var isCurrentUserProfile: Bool = true
    @State private var isUserInfoVisible: Bool = true
    @State private var pauseLazyModeFlag: Bool = false
    
    private let userIconSize: CGFloat = 80
    
    init(username: String) {
        _userDetailsViewModel = StateObject(
            wrappedValue: UserDetailsViewModel(
                username: username,
                userDetailsRepository: UserDetailsRepository()
            )
        )
    }
    
    var body: some View {
        RootView {
            GeometryReader { proxy in
                VStack(spacing: 0) {
                    if isUserInfoVisible {
                        VStack(spacing: 0) {
                            CustomWebImage(
                                userDetailsViewModel.userData?.banner,
                                width: UIScreen.main.bounds.width,
                                height: 150,
                                handleImageTapGesture: false,
                                centerCrop: true,
                                fallbackView: {
                                    Color(hex: themeViewModel.currentCustomTheme.colorPrimary)
                                        .frame(height: proxy.safeAreaInsets.top)
                                }
                            )
                            
                            HStack(spacing: 0) {
                                CustomWebImage(
                                    userDetailsViewModel.userData?.iconUrl,
                                    width: userIconSize,
                                    height: userIconSize,
                                    circleClipped: true,
                                    handleImageTapGesture: false,
                                    fallbackView: {
                                        InitialLetterAvatarImageFallbackView(name: userDetailsViewModel.userData?.name ?? "", size: userIconSize)
                                    }
                                )
                                
                                VStack(alignment: .leading, spacing: 5) {
                                    Text("u/\(userDetailsViewModel.userData?.name ?? userDetailsViewModel.username)")
                                        .username()
                                    
                                    Button(userDetailsViewModel.userData?.isSubscribed ?? false ? "Followed" : "Follow") {
                                        userDetailsViewModel.toggleFollowUser()
                                    }
                                    .filledButton()
                                }
                                .padding(.horizontal, 16)
                                
                                Spacer()
                            }
                            .padding(16)
                            
                            HStack {
                                Text("Karma: \(userDetailsViewModel.userData?.totalKarma ?? 0)")
                                    .primaryText()
                                
                                Spacer()
                                
                                Text("Cake day: \(Utils.getFormattedCakeDay(userDetailsViewModel.userData?.cakeday ?? 0))")
                                    .primaryText()
                                    .padding(.leading, 20)
                            }
                            .padding(.bottom, 16)
                            .padding(.horizontal, 16)
                            
                            if let description = userDetailsViewModel.userData?.description, !description.isEmpty {
                                Markdown(description)
                                    .themedMarkdown()
                                    .padding(.horizontal, 16)
                                    .padding(.bottom, 16)
                                    .markdownLinkHandler { url in
                                        navigationManager.openLink(url)
                                    }
                            }
                        }
                        .transition(.move(edge: .top).combined(with: .opacity))
                        .animation(.easeInOut, value: isUserInfoVisible)
                    } else {
                        Spacer()
                            .frame(height: proxy.safeAreaInsets.top)
                            .transition(.move(edge: .bottom))
                            .animation(.easeInOut, value: isUserInfoVisible)
                    }
                    
                    TabView(selection: $selectedTab) {
                        Group {
                            PostListingView(
                                postListingMetadata:PostListingMetadata(
                                    postListingType:.user(username: userDetailsViewModel.username, userWhere: .submitted),
                                    pathComponents: ["username": "\(userDetailsViewModel.username)"],
                                    headers: APIUtils.getOAuthHeader(accessToken: accountViewModel.account.accessToken ?? ""),
                                    queries: nil,
                                    params: nil
                                ),
                                isRootView: true,
                                pauseLazyModeExternalFlag: pauseLazyModeFlag,
                                onStartLazyMode: {
                                    if isUserInfoVisible {
                                        withAnimation {
                                            isUserInfoVisible = false
                                        }
                                    }
                                },
                                onScroll: {
                                    if isUserInfoVisible {
                                        withAnimation {
                                            isUserInfoVisible = false
                                        }
                                    }
                                }
                            )
                            .tabItem {
                                Label("Posts", systemImage: "list.bullet.rectangle")
                            }
                            .tag(0)
                            
                            CommentListingView(
                                commentListingMetadata: CommentListingMetadata(
                                    commentListingType:.user(username: userDetailsViewModel.username),
                                    pathComponents: ["username": "\(userDetailsViewModel.username)"],
                                    headers: APIUtils.getOAuthHeader(accessToken: accountViewModel.account.accessToken ?? ""),
                                    queries: nil
                                ),
                                onScroll: {
                                    if isUserInfoVisible {
                                        withAnimation {
                                            isUserInfoVisible = false
                                        }
                                    }
                                }
                            )
                            .tabItem {
                                Label("Comments", systemImage: "text.bubble")
                            }
                            .tag(1)
                        }
                        .themedTabViewGroup()
                        .toolbar(tabBarVisibility, for: .tabBar)
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                                tabBarVisibility = .visible
                            }
                        }
                        .onDisappear {
                            tabBarVisibility = .hidden
                        }
                        .animation(.easeInOut(duration: 0.2), value: tabBarVisibility)
                    }
                    .themedTabView()
                    .animation(.bouncy, value: navigationManager.rootTabLabelVisibility)
                }
                .overlay(alignment: .top) {
                    Color(hex: themeViewModel.currentCustomTheme.colorPrimary)
                        .frame(height: proxy.safeAreaInsets.top)
                        .opacity(isUserInfoVisible ? 0 : 1)
                        .ignoresSafeArea()
                }
                .edgesIgnoringSafeArea(.top)
            }
        }
        .task {
            if userDetailsViewModel.userData == nil {
                await userDetailsViewModel.fetchUserDetails()
            }
        }
        .themedNavigationBar()
        .toolbar {
            ToolbarItem(placement: .principal) {
                HStack(spacing: 4) {
                    Text("u/\(userDetailsViewModel.userData?.name ?? userDetailsViewModel.username)")
                        .navigationBarPrimaryText()
                    
                    SwiftUI.Image(systemName: "chevron.down.circle")
                        .resizable()
                        .frame(width: 16, height: 16)
                        .navigationBarPrimaryText()
                        .rotationEffect(.degrees(isUserInfoVisible ? 180 : 0))
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    withAnimation {
                        isUserInfoVisible.toggle()
                    }
                }
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                NavigationBarMenu()
            }
        }
        .toolbarBackground(.hidden, for: .navigationBar)
        .onAppear {
            if let key = navigationBarMenuKey {
                navigationBarMenuManager.pop(key: key)
            }
            navigationBarMenuKey = navigationBarMenuManager.push([
                NavigationBarMenuItem(title: "Add to Post Filter") {
                    navigationManager.append(SettingsViewNavigation.postFilter(userToBeAdded: userDetailsViewModel.userData?.name ?? userDetailsViewModel.username))
                },
                
                NavigationBarMenuItem(title: "Send Message") {
                    navigationManager.append(AppNavigation.sendChatMessage(recipient: userDetailsViewModel.userData?.name ?? userDetailsViewModel.username))
                }
            ])
        }
        .onDisappear {
            guard let navigationBarMenuKey else {
                return
            }
            navigationBarMenuManager.pop(key: navigationBarMenuKey)
        }
    }
}
