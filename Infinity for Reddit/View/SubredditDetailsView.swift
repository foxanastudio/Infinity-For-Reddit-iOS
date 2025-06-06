//
// SubredditDetailsView.swift
// Infinity for Reddit
//
// Created by joeylr2042 on 2025-05-01

import SwiftUI
import MarkdownUI
import SDWebImageSwiftUI

enum ProfileSection: String, CaseIterable, Identifiable {
    case posts = "Posts"
    case about = "About"
    
    var id: String { self.rawValue }
}

struct SubredditDetailsView: View {
    @EnvironmentObject var accountViewModel: AccountViewModel
    @EnvironmentObject var themeViewModel: CustomThemeViewModel
    @EnvironmentObject var navigationBarMenuManager: NavigationBarMenuManager
    
    @State private var isHeaderVisible = false
    @State private var isToolbarBackgroundVisible = true
    @State private var subscribeTask: Task<Void, Never>?
    @State private var selectedSection: ProfileSection = .posts
    @State private var headerMinY: CGFloat = 0
    
    @StateObject var subredditDetailsViewModel : SubredditDetailsViewModel
    
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
                if let subredditData = subredditDetailsViewModel.subredditData {
                    let height = 150.0
                    GeometryReader { headerProxy in
                        let headerMinY = headerProxy.frame(in: .named("SCROLL")).minY
                        let dynamicHeight = max(0, 150 + headerMinY)
                        
                        CustomWebImage(
                            subredditData.bannerUrl,
                            width: UIScreen.main.bounds.width,
                            height: dynamicHeight,
                            centerCrop: true,
                            fallbackView: {
                                Color(hex: themeViewModel.currentCustomTheme.colorPrimary)
                                    .frame(height: dynamicHeight)
                            }
                        )
                        .ignoresSafeArea(.container, edges: .top)
                        .offset(y: -headerMinY)
                        .onChange(of: headerMinY) {
                            self.headerMinY = headerMinY
                        }
                    }
                    .listPlainItemNoInsets()
                    .frame(height: height)
                    
                    VStack(spacing: 0) {
                        HStack(spacing: 0) {
                            CustomWebImage(
                                subredditData.iconUrl,
                                width: 80,
                                height: 80,
                                circleClipped: true
                            )
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("r/\(subredditData.name)")
                                    .subreddit()
                                
                                Button(action: {
                                    subscribeTask?.cancel()
                                    subscribeTask = Task {
                                        await subredditDetailsViewModel.toggleSubscribeSubreddit()
                                    }
                                }) {
                                    Text(subredditDetailsViewModel.isSubscribed ? "Subscribed" : "Subscribe")
                                        .padding(.horizontal, 15)
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
                                Text("Subscribers: \(subredditData.nSubscribers ?? 0)")
                                    .primaryText()
                                
                                Spacer()
                                
                                Text("Since:")
                                    .primaryText()
                            }
                            
                            HStack {
                                Text("Online: \(subredditData.activeUsers ?? 0)")
                                    .primaryText()
                                
                                Spacer()
                                
                                Text("\(subredditDetailsViewModel.formattedCakeDay(TimeInterval(subredditData.createdUTC ?? 0)))")
                                    .primaryText()
                            }
                        }
                        //                        .padding(.horizontal, 16)
                        .padding(.bottom, 16)
                        
                        if subredditData.sidebarDescription?.isEmpty ?? true == false {
                            subredditData.sidebarDescription.map {
                                Markdown($0)
                                    .themedMarkdown()
                                    .padding(.leading, 4)
                                    .padding(.bottom, 16)
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .listPlainItemNoInsets()
                    
                    Picker("Select Section", selection: $selectedSection) {
                        ForEach(ProfileSection.allCases) { section in
                            Text(section.rawValue).tag(section)
                        }
                    }
                    .pickerStyle(.segmented)
                    .listRowInsets(EdgeInsets(top: 10, leading: 16, bottom: 10, trailing: 16))
                    
                    switch selectedSection {
                    case .posts:
                        PostListingView(
                            account: accountViewModel.account,
                            postListingMetadata:PostListingMetadata(
                                postListingType:.subreddit,
                                pathComponents: ["sortType": "hot", "subreddit": "\(subredditData.name)"],
                                headers: APIUtils.getOAuthHeader(accessToken: accountViewModel.account.accessToken ?? ""),
                                queries: nil,
                                params: nil
                            ),
                            isRootView: false
                        )
                        .id(accountViewModel.account.username)
                        .listRowSeparator(.hidden)
                        .padding(.horizontal, 16)
                    case .about:
                        SubredditAboutView(description: subredditData.description)
                        .listRowSeparator(.hidden)
                    }
                }
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
            .overlay(alignment: .top) {
                let scrollThreshold: CGFloat = 100.0
                let opacity = min(1, max(0, (-headerMinY / scrollThreshold)))
                
                ZStack {
                    Color(hex: themeViewModel.currentCustomTheme.colorPrimary)
                    
                    Text("r/\(subredditDetailsViewModel.subredditData?.name ?? "")")
                        .navigationBarPrimaryText()
                        .padding(.top, proxy.safeAreaInsets.top)
                }
                .frame(height: (proxy.safeAreaInsets.top) + 30)
                .opacity(opacity)
                .ignoresSafeArea()
            }
        }
    }
}
