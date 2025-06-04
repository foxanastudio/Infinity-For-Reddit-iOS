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
    
    @State private var isHeaderVisible = false
    @State private var isToolbarBackgroundVisible = true
    @State private var subscribeTask: Task<Void, Never>?
    
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
        List {
            if let subredditData = subredditDetailsViewModel.subredditData {
                CustomWebImage(
                    subredditData.bannerUrl,
                    width: UIScreen.main.bounds.width,
                    height: 150,
                    centerCrop: true,
                    fallbackView: {
                        Color(hex: themeViewModel.currentCustomTheme.colorPrimary)
                            .frame(height: 150)
                    }
                )
                .listPlainItemNoInsets()
                
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
                    .padding(.horizontal, 16)
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
                .listPlainItemNoInsets()
                
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
            }
        }
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
    }
}
