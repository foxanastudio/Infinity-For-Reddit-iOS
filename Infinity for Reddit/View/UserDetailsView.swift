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
    
    @StateObject var userDetailsViewModel : UserDetailsViewModel
    @State private var selectedTab = 0
    @State private var isCurrentUserProfile: Bool = true
    
    @State private var infoVisible: Bool = true
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
                    if infoVisible {
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
                                .padding(.vertical, 20)
                                
                                VStack(alignment: .leading, spacing: 5) {
                                    Text("u/\(userDetailsViewModel.userData?.name ?? userDetailsViewModel.username)")
                                        .username()
                                        .font(.title2)
                                        .bold()
                                    
                                    Button(action: {
                                        userDetailsViewModel.toggleFollowUser()
                                    }) {
                                        Text(userDetailsViewModel.userData?.isSubscribed ?? false ? "Followed" : "Follow")
                                            .padding(.horizontal, 15)
                                            .padding(.vertical, 8)
                                            .background(Color.blue)
                                            .foregroundColor(.white)
                                            .cornerRadius(20)
                                    }
                                }
                                .padding(.leading, 10)
                                
                                Spacer()
                            }
                            .padding(.horizontal, 16)
                            
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
                        .animation(.easeInOut, value: infoVisible)
                    } else {
                        Spacer()
                            .frame(height: proxy.safeAreaInsets.top)
                            .transition(.move(edge: .bottom))
                            .animation(.easeInOut, value: infoVisible)
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
                                    if infoVisible {
                                        withAnimation {
                                            infoVisible = false
                                        }
                                    }
                                },
                                onScroll: {
                                    if infoVisible {
                                        withAnimation {
                                            infoVisible = false
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
                                    if infoVisible {
                                        withAnimation {
                                            infoVisible = false
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
                    }
                    .themedTabView()
                }
                .overlay(alignment: .top) {
                    Color(hex: themeViewModel.currentCustomTheme.colorPrimary)
                        .frame(height: proxy.safeAreaInsets.top)
                        .opacity(infoVisible ? 0 : 1)
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
                        .rotationEffect(.degrees(infoVisible ? 180 : 0))
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    withAnimation {
                        infoVisible.toggle()
                    }
                }
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                NavigationBarMenu()
            }
        }
        .toolbar(.hidden, for: .tabBar)
        .toolbarBackground(.hidden, for: .navigationBar)
    }
}
