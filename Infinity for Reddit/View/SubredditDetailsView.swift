//
// SubredditDetailsView.swift
// Infinity for Reddit
//
// Created by joeylr2042 on 2025-05-01

import SwiftUI
import MarkdownUI
import SDWebImageSwiftUI

struct SubredditDetailsView: View {
    @Environment(\.dismiss) private var dismiss
    
    @EnvironmentObject private var accountViewModel: AccountViewModel
    @EnvironmentObject private var themeViewModel: CustomThemeViewModel
    @EnvironmentObject private var navigationBarMenuManager: NavigationBarMenuManager
    @EnvironmentObject private var navigationManager: NavigationManager
    
    @StateObject var subredditDetailsViewModel : SubredditDetailsViewModel
    
    @State private var navigationBarMenuKey: UUID?
    @State private var showSubredditAboutSheet: Bool = false
    @State private var isSubredditInfoVisible: Bool = true
    @State private var showUserFlairSheet: Bool = false
    
    private let subredditIconSize: CGFloat = 80
    private let bannerMaxHeight: CGFloat = 150
    
    private var navigationTitleText: String {
        "r/\(subredditDetailsViewModel.subredditData?.name ?? subredditDetailsViewModel.subredditName)"
    }
    
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
                        ScrollView {
                            VStack(spacing: 0) {
                                CustomWebImage(
                                    proxy.size.height < 500 ? nil : subredditDetailsViewModel.subredditData?.bannerUrl,
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
                                        .subscribeButton(isSubscribed: subredditDetailsViewModel.subredditData?.isSubscribed ?? false)
                                    }
                                    .padding(.horizontal, 16)
                                    
                                    Spacer()
                                }
                                .padding(16)
                                
                                if let description = subredditDetailsViewModel.subredditData?.description, !description.isEmpty {
                                    Markdown(description)
                                        .themedMarkdown()
                                        .frame(maxHeight: .infinity)
                                        .padding(.horizontal, 16)
                                        .padding(.bottom, 16)
                                        .markdownLinkHandler { url in
                                            navigationManager.openLink(url)
                                        }
                                }
                            }
                            .transition(.move(edge: .top).combined(with: .opacity))
                            .animation(.easeInOut, value: isSubredditInfoVisible)
                        }
                        .frame(maxHeight: getScreenHeight(proxy) / 2)
                        .fixedSize(horizontal: false, vertical: true)
                    } else {
                        Spacer()
                            .frame(height: proxy.safeAreaInsets.top)
                            .transition(.move(edge: .bottom))
                            .animation(.easeInOut, value: isSubredditInfoVisible)
                    }
                    
                    PostListingView(
                        postListingMetadata: PostListingMetadata(
                            postListingType:.subreddit(subredditName: subredditDetailsViewModel.subredditName),
                            pathComponents: ["subreddit": "\(subredditDetailsViewModel.subredditName)"],
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
                                                    isSubredditInfoVisible ? .clear : Color(hex: themeViewModel.currentCustomTheme.colorPrimary)
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
                .onChange(of: proxy.size) { _, newValue in
                    if getScreenHeight(proxy) < 500 {
                        isSubredditInfoVisible = false
                    }
                }
            }
        }
        .task {
            if subredditDetailsViewModel.subredditData == nil {
                await subredditDetailsViewModel.fetchSubredditDetails()
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
                        .rotationEffect(.degrees(isSubredditInfoVisible ? 180 : 0))
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
        .onAppear {
            if let key = navigationBarMenuKey {
                navigationBarMenuManager.pop(key: key)
            }
            navigationBarMenuKey = navigationBarMenuManager.push([
                NavigationBarMenuItem(title: "Search") {
                    navigationManager.append(AppNavigation.search(searchInSubreddit: subredditDetailsViewModel.subredditData))
                },
                
                NavigationBarMenuItem(title: "Select User Flair") {
                    subredditDetailsViewModel.fetchUserFlairs()
                    showUserFlairSheet = true
                },
                
                NavigationBarMenuItem(title: "Add to Post Filter") {
                    navigationManager.append(SettingsViewNavigation.postFilter(subredditToBeAdded: subredditDetailsViewModel.subredditData?.name ?? subredditDetailsViewModel.subredditName))
                },
                
                NavigationBarMenuItem(title: "Contact Mods") {
                    navigationManager.append(AppNavigation.sendChatMessage(recipient: "r/\(subredditDetailsViewModel.subredditData?.name ?? subredditDetailsViewModel.subredditName)"))
                },
                
                NavigationBarMenuItem(title: "Wiki") {
                    navigationManager.append(AppNavigation.wiki(subredditName: subredditDetailsViewModel.subredditData?.name ?? subredditDetailsViewModel.subredditName))
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
        .sheet(isPresented: $showSubredditAboutSheet) {
            SubredditAboutSheet(subredditData: subredditDetailsViewModel.subredditData)
        }
        .wrapContentSheet(isPresented: $showUserFlairSheet) {
            SelectUserFlairSheet(userFlairs: subredditDetailsViewModel.userFlairs, onUserFlairSelected: { userFlair in
                subredditDetailsViewModel.selectUserFlair(userFlair)
            }, onClearUserFlair: {
                subredditDetailsViewModel.cleaarUserFlair()
            })
        }
        .overlay(
            CustomAlert(
                title: "NSFW Subreddit",
                subtitle: "This subreddit is marked as NSFW. You can only go back.",
                confirmButtonText: "Go Back",
                buttonStyle: .info,
                showDismissButton: false,
                canDismissByTapOutside: false,
                isPresented: $subredditDetailsViewModel.showSensitiveSubredditWarningTrigger
            ) {} onConfirm: {
                dismiss()
            }
        )
    }
    
    func getScreenHeight(_ proxy: GeometryProxy) -> CGFloat {
        return proxy.size.height + proxy.safeAreaInsets.top + proxy.safeAreaInsets.bottom
    }
}
