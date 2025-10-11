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
    
    @State private var isHeaderVisible = false
    @State private var isToolbarBackgroundVisible = true
    @State private var subscribeTask: Task<Void, Never>?
    @State private var selectedSection: Int = 0
    @State private var headerMinY: CGFloat = 0
    @State private var isManuallyRefreshing = false
    @State private var isDragging = false
    @State private var isReadyToRefresh = false
    
    @StateObject var subredditDetailsViewModel : SubredditDetailsViewModel
    
    private let subredditIconSize: CGFloat = 80
    
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
            List {
                VStack(spacing: 0) {
                    let height = 150.0
                    GeometryReader { headerProxy in
                        let currentHeaderMinY = headerProxy.frame(in: .named("SCROLL")).minY
                        let dynamicHeight = max(0, height + currentHeaderMinY * 0.4)
                        let bannerOpacity = max(0, 1 + (currentHeaderMinY / 150))
                        
                        VStack(alignment: .center) {
                            CustomWebImage(
                                subredditDetailsViewModel.subredditData?.bannerUrl ?? "",
                                width: UIScreen.main.bounds.width,
                                height: dynamicHeight,
                                handleImageTapGesture: false,
                                centerCrop: true,
                                fallbackView: {
                                    Color(hex: themeViewModel.currentCustomTheme.colorPrimary)
                                        .frame(height: dynamicHeight)
                                        .opacity(bannerOpacity)
                                }
                            )
                            .opacity(bannerOpacity)
                            
                            HStack {
                                ProgressIndicator()
                                    .opacity(isManuallyRefreshing || isReadyToRefresh ? 1 : 0)
                                    .offset(y: -10)
                            }
                            .frame(height: isManuallyRefreshing || isReadyToRefresh ? 60 : 0)
                            .clipped()
                            
                        }
                        .ignoresSafeArea(.container, edges: .top)
                        .offset(y: -currentHeaderMinY)
                        .onChange(of: currentHeaderMinY) { _, newValue in
                            self.headerMinY = newValue
                            let refreshThreshold: CGFloat = 65.0
                            
                            if isManuallyRefreshing { return }
                            
                            if isDragging && newValue > refreshThreshold {
                                self.isReadyToRefresh = true
                            }
                            
                            if !isDragging || newValue < refreshThreshold {
                                self.isReadyToRefresh = false
                            }
                        }
                    }
                    .frame(height: height)
                    
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
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("r/\(subredditDetailsViewModel.subredditData?.name ?? subredditDetailsViewModel.subredditName)")
                                    .subreddit()
                                
                                Button(action: {
                                    subscribeTask?.cancel()
                                    subscribeTask = Task {
                                        await subredditDetailsViewModel.toggleSubscribeSubreddit()
                                    }
                                }) {
                                    Text(subredditDetailsViewModel.isSubscribed ? "Subscribed" : "Subscribe")
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .background(Color.blue)
                                        .foregroundColor(.white)
                                        .cornerRadius(20)
                                }
                            }
                            .padding(.leading, 16)
                            
                            Spacer()
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 16)
                        
                        VStack(alignment: .leading) {
                            HStack {
                                Text("Subscribers: \(subredditDetailsViewModel.subredditData?.nSubscribers ?? 0)")
                                    .primaryText()
                                
                                Spacer()
                                
                                Text("Since:")
                                    .primaryText()
                            }
                            
                            HStack {
                                Spacer()
                                
                                if let subredditData = subredditDetailsViewModel.subredditData {
                                    Text("\(subredditDetailsViewModel.formattedCakeDay(TimeInterval(subredditData.createdUTC ?? 0)))")
                                        .primaryText()
                                }
                            }
                        }
                        .padding(.bottom, 16)
                        
                        if let description = subredditDetailsViewModel.subredditData?.sidebarDescription, !description.isEmpty {
                            Markdown(description)
                                .themedMarkdown()
                                .padding(.bottom, 8)
                                .markdownLinkHandler { url in
                                    navigationManager.openLink(url)
                                }
                        }
                    }
                    .padding(.horizontal, 16)
                    .offset(y: isManuallyRefreshing || isReadyToRefresh ? 30 : 0)
                }
                .listPlainItemNoInsets()
                .zIndex(2)
                
                SegmentedPicker(selectedValue: $selectedSection, values: ["Posts", "About"])
                    .padding(4)
                    .listRowInsets(EdgeInsets(top: 10, leading: 16, bottom: 10, trailing: 16))
                    .offset(y: isManuallyRefreshing || isReadyToRefresh ? 30 : 0)
                    .zIndex(0)
                    .animation(.easeInOut, value: selectedSection)
                    .frame(maxWidth: .infinity)
                
                Group {
                    if selectedSection == 0 {
                        PostListingView(
                            account: accountViewModel.account,
                            postListingMetadata:PostListingMetadata(
                                postListingType:.subreddit(subredditName: subredditDetailsViewModel.subredditName),
                                pathComponents: ["subreddit": "\(subredditDetailsViewModel.subredditName)"],
                                headers: APIUtils.getOAuthHeader(accessToken: accountViewModel.account.accessToken ?? ""),
                                queries: nil,
                                params: nil
                            ),
                            isRootView: false
                        )
                        .id(accountViewModel.account.username)
                        .listRowSeparator(.hidden)
                        .offset(y: isManuallyRefreshing || isReadyToRefresh ? 30 : 0)
                    } else if selectedSection == 1 {
                        SubredditAboutView(subredditData: subredditDetailsViewModel.subredditData)
                            .listRowSeparator(.hidden)
                    }
                }
                .animation(.easeInOut, value: selectedSection)
            }
            .coordinateSpace(name: "SCROLL")
            .edgesIgnoringSafeArea(.top)
            .themedList()
            .themedNavigationBar()
            .task {
                if subredditDetailsViewModel.subredditData == nil {
                    await subredditDetailsViewModel.fetchSubredditDetails()
                }
            }
            .toolbarBackground(.hidden, for: .navigationBar)
            .toolbar {
                NavigationBarMenu()
            }
            .simultaneousGesture(
                DragGesture(minimumDistance: 5)
                    .onChanged { _ in
                        if !self.isDragging {
                            self.isDragging = true
                        }
                    }
                    .onEnded { _ in
                        self.isDragging = false
                        
                        if self.isReadyToRefresh {
                            withAnimation(.easeInOut) {
                                self.isManuallyRefreshing = true
                                self.isReadyToRefresh = false
                            }
                            
                            Task {
                                await subredditDetailsViewModel.fetchSubredditDetails()
                                try? await Task.sleep(for: .seconds(0.5))
                                withAnimation(.easeInOut) {
                                    self.isManuallyRefreshing = false
                                }
                            }
                        }
                    }
            )
            .overlay(alignment: .top) {
                let scrollThreshold: CGFloat = 150.0
                let opacity = min(1, max(0, (-headerMinY / scrollThreshold)))
                
                Color(hex: themeViewModel.currentCustomTheme.colorPrimary)
                    .frame(height: proxy.safeAreaInsets.top)
                    .opacity(opacity)
                    .ignoresSafeArea()
            }
            .addTitleToInlineNavigationBar(
                "r/\(subredditDetailsViewModel.subredditData?.name ?? "")",
                {
                    let scrollThreshold: CGFloat = 150.0
                    return min(1, max(0, (-headerMinY / scrollThreshold)))
                }()
            )
        }
    }
}
