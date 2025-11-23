//
// SubredditDetailsView.swift
// Infinity for Reddit
//
// Created by joeylr2042 on 2025-05-01

import SwiftUI
import MarkdownUI
import SDWebImageSwiftUI

struct SubredditDetailsView: View {
    @EnvironmentObject var accountViewModel: AccountViewModel
    @EnvironmentObject var themeViewModel: CustomThemeViewModel
    @EnvironmentObject var navigationBarMenuManager: NavigationBarMenuManager
    @EnvironmentObject private var navigationManager: NavigationManager
    
    @StateObject var subredditDetailsViewModel : SubredditDetailsViewModel
    
    @State private var navigationBarMenuKey: UUID?
    @State private var showSubredditAboutSheet: Bool = false
    @State private var isSubredditInfoVisible: Bool = true
    @State private var showUserFlairSheet: Bool = false
    
    private let subredditIconSize: CGFloat = 80
    private let bannerMaxHeight: CGFloat = 150
    
    init(subredditName: String) {
        _subredditDetailsViewModel = StateObject(
            wrappedValue: SubredditDetailsViewModel(
                subredditName: subredditName,
                subredditDetailsRepository: SubredditDetailsRepository()
            )
        )
    }
    
    var body: some View {
        RootView {
            GeometryReader { proxy in
                VStack(spacing: 0) {
                    if isSubredditInfoVisible {
                        VStack(spacing: 0) {
                            CustomWebImage(
                                subredditDetailsViewModel.subredditData?.bannerUrl,
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
                                    subredditDetailsViewModel.subredditData?.iconUrl,
                                    width: subredditIconSize,
                                    height: subredditIconSize,
                                    circleClipped: true,
                                    handleImageTapGesture: false,
                                    fallbackView: {
                                        InitialLetterAvatarImageFallbackView(name: subredditDetailsViewModel.subredditData?.name ?? subredditDetailsViewModel.subredditName, size: subredditIconSize)
                                    }
                                )
                                
                                VStack(alignment: .leading) {
                                    Text("r/\(subredditDetailsViewModel.subredditData?.name ?? subredditDetailsViewModel.subredditName)")
                                        .subreddit()
                                    
                                    Button("\(subredditDetailsViewModel.subredditData?.isSubscribed ?? false ? "Subscribed" : "Subscribe") \(subredditDetailsViewModel.subredditData?.nSubscribers ?? 0)") {
                                        subredditDetailsViewModel.toggleSubscribeSubreddit()
                                    }
                                    .filledButton()
                                }
                                .padding(.horizontal, 16)
                                
                                Spacer()
                            }
                            .padding(16)
                            
                            if let description = subredditDetailsViewModel.subredditData?.sidebarDescription, !description.isEmpty {
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
                        .animation(.easeInOut, value: isSubredditInfoVisible)
                    } else {
                        Spacer()
                            .frame(height: proxy.safeAreaInsets.top)
                            .transition(.move(edge: .bottom))
                            .animation(.easeInOut, value: isSubredditInfoVisible)
                    }
                    
                    PostListingView(
                        postListingMetadata:PostListingMetadata(
                            postListingType:.subreddit(subredditName: subredditDetailsViewModel.subredditName),
                            pathComponents: ["subreddit": "\(subredditDetailsViewModel.subredditName)"],
                            headers: APIUtils.getOAuthHeader(accessToken: accountViewModel.account.accessToken ?? ""),
                            queries: nil,
                            params: nil
                        ),
                        pauseLazyModeExternalFlag: showSubredditAboutSheet,
                        onStartLazyMode: {
                            if isSubredditInfoVisible {
                                withAnimation {
                                    isSubredditInfoVisible = false
                                }
                            }
                        },
                        onScroll: {
                            if isSubredditInfoVisible {
                                withAnimation {
                                    isSubredditInfoVisible = false
                                }
                            }
                        }
                    )
                }
                .edgesIgnoringSafeArea(.top)
                .overlay(alignment: .top) {
                    Color(hex: themeViewModel.currentCustomTheme.colorPrimary)
                        .frame(height: proxy.safeAreaInsets.top)
                        .opacity(isSubredditInfoVisible ? 0 : 1)
                        .ignoresSafeArea()
                }
            }
        }
        .task {
            if subredditDetailsViewModel.subredditData == nil {
                await subredditDetailsViewModel.fetchSubredditDetails()
            }
        }
        .toolbarBackground(.hidden, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .principal) {
                HStack(spacing: 4) {
                    Text("u/\(subredditDetailsViewModel.subredditData?.name ?? subredditDetailsViewModel.subredditName)")
                        .navigationBarPrimaryText()
                    
                    SwiftUI.Image(systemName: "chevron.down.circle")
                        .resizable()
                        .frame(width: 16, height: 16)
                        .navigationBarPrimaryText()
                        .rotationEffect(.degrees(isSubredditInfoVisible ? 180 : 0))
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    withAnimation {
                        isSubredditInfoVisible.toggle()
                    }
                }
            }
            
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Button(action: {
                    showSubredditAboutSheet = true
                }) {
                    SwiftUI.Image(systemName: "info.circle")
                        .navigationBarImage()
                }
                
                NavigationBarMenu()
            }
        }
        .id(accountViewModel.account.username)
        .onAppear {
            if let key = navigationBarMenuKey {
                navigationBarMenuManager.pop(key: key)
            }
            navigationBarMenuKey = navigationBarMenuManager.push([
                NavigationBarMenuItem(title: "Select User Flair") {
                    subredditDetailsViewModel.fetchUserFlairs()
                    showUserFlairSheet = true
                },
                
                NavigationBarMenuItem(title: "Add to Post Filter") {
                    navigationManager.append(SettingsViewNavigation.postFilter(subredditToBeAdded: subredditDetailsViewModel.subredditData?.name ?? subredditDetailsViewModel.subredditName))
                },
                
                NavigationBarMenuItem(title: "Contact Mods") {
                    navigationManager.append(AppNavigation.sendChatMessage(recipient: "r/\(subredditDetailsViewModel.subredditData?.name ?? subredditDetailsViewModel.subredditName)"))
                }
            ])
        }
        .onDisappear {
            guard let navigationBarMenuKey else {
                return
            }
            navigationBarMenuManager.pop(key: navigationBarMenuKey)
        }
        .wrapContentSheet(isPresented: $showSubredditAboutSheet) {
            SubredditAboutSheet(subredditData: subredditDetailsViewModel.subredditData)
        }
        .wrapContentSheet(isPresented: $showUserFlairSheet) {
            SelectUserFlairSheet(userFlairs: subredditDetailsViewModel.userFlairs, onUserFlairSelected: { userFlair in
                subredditDetailsViewModel.selectUserFlair(userFlair)
            }, onClearUserFlair: {
                subredditDetailsViewModel.cleaarUserFlair()
            })
        }
    }
}
