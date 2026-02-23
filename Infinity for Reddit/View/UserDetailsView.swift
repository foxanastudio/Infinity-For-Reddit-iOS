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
    @State private var selectedTab = 0
    @State private var isCurrentUserProfile: Bool = true
    @State private var isUserInfoVisible: Bool = true
    @State private var pauseLazyModeFlag: Bool = false
    
    private let userIconSize: CGFloat = 80
    
    private var navigationTitleText: String {
        "u/\(userDetailsViewModel.userData?.name ?? userDetailsViewModel.username)"
    }
    
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
                                width: proxy.size.width,
                                height: 150,
                                handleImageTapGesture: false,
                                centerCrop: true,
                                fallbackView: {
                                    if #available(iOS 26, *) {
                                        Color.clear
                                            .frame(height: proxy.safeAreaInsets.top)
                                    } else {
                                        Color(hex: themeViewModel.currentCustomTheme.colorPrimary)
                                            .frame(height: proxy.safeAreaInsets.top)
                                    }
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
                                    .subscribeButton(isSubscribed: userDetailsViewModel.userData?.isSubscribed ?? false)
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
                    
                    SegmentedPicker(
                        selectedValue: $selectedTab,
                        values: ["Posts", "Comments"]
                    )
                    .padding(4)
                    
                    ZStack {
                        PostListingView(
                            postListingMetadata:PostListingMetadata(
                                postListingType:.user(username: userDetailsViewModel.username, userWhere: .submitted),
                                pathComponents: ["username": "\(userDetailsViewModel.username)"],
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
                            },
                            isPresented: selectedTab == 0
                        )
                        .opacity(selectedTab == 0 ? 1 : 0)
                        .allowsHitTesting(selectedTab == 0)
                        
                        CommentListingView(
                            commentListingMetadata: CommentListingMetadata(
                                commentListingType:.user(username: userDetailsViewModel.username),
                                pathComponents: ["username": "\(userDetailsViewModel.username)"],
                                queries: nil
                            ),
                            isPresented: selectedTab == 1,
                            onScroll: {
                                if isUserInfoVisible {
                                    withAnimation {
                                        isUserInfoVisible = false
                                    }
                                }
                            }
                        )
                        .opacity(selectedTab == 1 ? 1 : 0)
                        .allowsHitTesting(selectedTab == 1)
                    }
                }
                .modify {
                    if #available(iOS 26, *) {
                        $0
                    } else {
                        $0.overlay(alignment: .top) {
                            Rectangle()
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(
                                            colors: [
                                                Color(hex: themeViewModel.currentCustomTheme.colorPrimary),
                                                isUserInfoVisible ? .clear : Color(hex: themeViewModel.currentCustomTheme.colorPrimary)
                                            ]
                                        ),
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .frame(height: proxy.safeAreaInsets.top)
                                .ignoresSafeArea()
                        }
                    }
                }
                .edgesIgnoringSafeArea(.top)
            }
        }
        .task {
            if userDetailsViewModel.userData == nil {
                await userDetailsViewModel.fetchUserDetails()
            }
        }
        .toolbarBackground(.hidden, for: .navigationBar)
        .navigationTitle(navigationTitleText)
        .toolbar {
            ToolbarItem(placement: .principal) {
                HStack(spacing: 4) {
                    Text(navigationTitleText)
                        .navigationBarPrimaryText()
                    
                    SwiftUI.Image(systemName: "chevron.down.circle")
                        .resizable()
                        .frame(width: 16, height: 16)
                        .navigationBarPrimaryText()
                        .rotationEffect(.degrees(isUserInfoVisible ? 180 : 0))
                }
                .modify {
                    if #available(iOS 26, *) {
                        $0.navigationBarTitleGlassEffect()
                    } else {
                        $0
                    }
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
                },
                
                NavigationBarMenuItem(title: "Report") {
                    navigationManager.openLink("https://www.reddit.com/report")
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
