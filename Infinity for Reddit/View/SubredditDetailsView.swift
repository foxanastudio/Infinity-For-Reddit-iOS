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

    @State private var subscribeTask: Task<Void, Never>?
    @State private var bannerMinY: CGFloat = 0
    @State private var bannerHeight: CGFloat = 0
    @State private var bannerOpacity: CGFloat = 0
    @State private var lazyModeStarted: Bool = false
    @State private var spacerHeight: CGFloat = 0
    @State private var headerItemViewHeight: CGFloat? = nil
    @State private var geoHeight: CGFloat = 150
    @State private var navigationBarOpacity: CGFloat = 0
    @State private var navigationBarMenuKey: UUID?
    @State private var showSubredditAboutSheet: Bool = false
    
    @StateObject var subredditDetailsViewModel : SubredditDetailsViewModel
    
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
        GeometryReader { proxy in
            VStack(spacing: 0) {
                Spacer()
                    .frame(height: spacerHeight)
                
                ScrollViewReader { scrollProxy in
                    List {
                        VStack(spacing: 0) {
                            GeometryReader { headerProxy in
                                let currentHeaderMinY = headerProxy.frame(in: .named("list")).minY
                                let dynamicHeight = max(0, bannerMaxHeight + currentHeaderMinY * 0.4)
                                let bannerOpacity = max(0, 1 + (currentHeaderMinY / bannerMaxHeight))
                                
                                VStack(alignment: .center) {
                                    CustomWebImage(
                                        subredditDetailsViewModel.subredditData?.bannerUrl ?? "",
                                        width: UIScreen.main.bounds.width,
                                        height: dynamicHeight,
                                        handleImageTapGesture: false,
                                        centerCrop: true,
                                        fallbackView: {
                                            Color(hex: themeViewModel.currentCustomTheme.colorAccent)
                                        }
                                    )
                                    .opacity(bannerOpacity)
                                }
                                .ignoresSafeArea(.container, edges: .top)
                                .onChange(of: currentHeaderMinY) { _, newValue in
                                    self.bannerMinY = newValue
                                    navigationBarOpacity = min(1, max(0, (-bannerMinY / bannerMaxHeight)))
                                }
                            }
                            .frame(height: geoHeight)
                            .clipped()
                            
                            VStack(spacing: 0) {
                                HStack(spacing: 0) {
                                    CustomWebImage(
                                        subredditDetailsViewModel.subredditData?.iconUrl ?? "",
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
                                        
                                        Button(subredditDetailsViewModel.isSubscribed ?
                                               "Subscribed \(subredditDetailsViewModel.subredditData?.nSubscribers ?? 0)"
                                               : "Subscribe \(subredditDetailsViewModel.subredditData?.nSubscribers ?? 0)") {
                                            subscribeTask?.cancel()
                                            subscribeTask = Task {
                                                await subredditDetailsViewModel.toggleSubscribeSubreddit()
                                            }
                                        }
                                        .filledButton()
                                        .frame(height: headerItemViewHeight)
                                        .clipped()
                                    }
                                    .padding(.leading, 16)
                                    .frame(height: headerItemViewHeight)
                                    .clipped()
                                    
                                    Spacer()
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 16)
                                .frame(height: headerItemViewHeight)
                                .clipped()
                                
                                if !lazyModeStarted, let description = subredditDetailsViewModel.subredditData?.sidebarDescription, !description.isEmpty {
                                    Markdown(description)
                                        .themedMarkdown()
                                        .padding(.bottom, 8)
                                        .markdownLinkHandler { url in
                                            navigationManager.openLink(url)
                                        }
                                }
                            }
                            .padding(.horizontal, 16)
                            .frame(height: headerItemViewHeight)
                            .clipped()
                        }
                        .listPlainItemNoInsets()
                        .frame(height: headerItemViewHeight)
                        .clipped()
                        .id(lazyModeStarted)
                        
                        PostListingView(
                            postListingMetadata:PostListingMetadata(
                                postListingType:.subreddit(subredditName: subredditDetailsViewModel.subredditName),
                                pathComponents: ["subreddit": "\(subredditDetailsViewModel.subredditName)"],
                                headers: APIUtils.getOAuthHeader(accessToken: accountViewModel.account.accessToken ?? ""),
                                queries: nil,
                                params: nil
                            ),
                            isRootView: false,
                            scrollProxy: scrollProxy,
                            pauseLazyModeExternalFlag: showSubredditAboutSheet,
                            onStartLazyMode: {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    lazyModeStarted = true
                                    setHeight(proxy)
                                }
                            },
                            onStopLazyMode: {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    navigationBarOpacity = 1
                                    lazyModeStarted = false
                                    setHeight(proxy)
                                }
                            }
                        )
                        .listRowSeparator(.hidden)
                    }
                    .coordinateSpace(name: "list")
                    .themedList()
                }
            }
            .edgesIgnoringSafeArea(.top)
            .overlay(alignment: .top) {
                Color(hex: themeViewModel.currentCustomTheme.colorPrimary)
                    .frame(height: proxy.safeAreaInsets.top)
                    .opacity(lazyModeStarted ? 1 : navigationBarOpacity)
                    .ignoresSafeArea()
            }
        }
        .addTitleToInlineNavigationBar(
            "r/\(subredditDetailsViewModel.subredditData?.name ?? "")",
            lazyModeStarted ? 1 : navigationBarOpacity
        )
        .task {
            if subredditDetailsViewModel.subredditData == nil {
                await subredditDetailsViewModel.fetchSubredditDetails()
            }
        }
        .toolbarBackground(.hidden, for: .navigationBar)
        .toolbar {
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
        .sheet(isPresented: $showSubredditAboutSheet) {
            SubredditAboutSheet(subredditData: subredditDetailsViewModel.subredditData)
        }
    }
    
    private func setHeight(_ proxy: GeometryProxy) {
        spacerHeight = lazyModeStarted ? proxy.safeAreaInsets.top : 0
        headerItemViewHeight = lazyModeStarted ? 0 : nil
        geoHeight = lazyModeStarted ? 0 : bannerMaxHeight
    }
}
