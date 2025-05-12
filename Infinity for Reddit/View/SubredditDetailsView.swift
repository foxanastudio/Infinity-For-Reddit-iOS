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
    
    @State var selectedTab = 0
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
        // Top Section (Subreddit Info)
        VStack(spacing: 0) {
            if let subredditData = subredditDetailsViewModel.subredditData {
                if let bannerUrl = subredditData.bannerUrl, !bannerUrl.isEmpty {
                    CustomWebImage(
                        subredditData.bannerUrl,
                        width: UIScreen.main.bounds.width,
                        height: 200,
                        centerCrop: true
                    )
                    //                        .offset(y: 10)
                    //                        .padding(.vertical, -10)
                    //                        WebImage(url: URL(string: bannerUrl))
                    //                                    .resizable()
                    //                                    .scaledToFill()
                    //                                    .frame(width: UIScreen.main.bounds.width, height: 200)
                    //                                    .clipped()
                }
                VStack(spacing: 0) {
                    HStack(spacing: 0) {
                        CustomWebImage(
                            subredditData.iconUrl,
                            width: 80,
                            height: 80,
                            circleClipped: true
                        )
                        .padding(.vertical, 30)
                        
                        VStack(alignment: .leading, spacing: 5) {
                            Text("r/\(subredditData.name)")
                                .username()
                                .font(.title2)
                                .bold()
                            
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
                        .padding(.leading, 10)
                        
                        Spacer()
                    }
                    
                    VStack(alignment: .leading) {
                        HStack {
                            Text("Subscribers: \(subredditData.nSubscribers ?? 0)")
                                .primaryText()
                            
                            Spacer()
                            
                            Text("Since: ")
                                .primaryText()
                        }
                        
                        HStack {
                            Text("Online: \(subredditData.activeUsers ?? 0)")
                                .primaryText()
                            
                            Spacer()
                            
                            Text("\(subredditDetailsViewModel.formattedCakeDay(TimeInterval(subredditData.createdUTC ?? 0)))")
                                .primaryText()
                                .padding(.leading, 20)
                        }
                    }
                    .padding(.bottom, 10)
                    
                    subredditData.sidebarDescription.map {
                        Markdown($0)
                            .themedMarkdown()
                            .padding(0)
                    }
                    
                    SegmentedPicker(selectedValue: $selectedTab, values: ["Posts", "About"])
                        .padding(4)
                }
                .padding(.horizontal, 20)
                
                ZStack {
                    PostListingView(
                        account: accountViewModel.account,
                        postListingMetadata:PostListingMetadata(
                            postListingType:.subreddit,
                            pathComponents: ["sortType": "hot", "subreddit": "\(subredditData.name)"],
                            headers: APIUtils.getOAuthHeader(accessToken: accountViewModel.account.accessToken ?? ""),
                            queries: nil,
                            params: nil
                        )
                    )
                    .id(accountViewModel.account.username)
                    .opacity(selectedTab == 0 ? 1 : 0)
                    
                    SubredditAboutView(description: subredditDetailsViewModel.subredditData!.description)
                        .opacity(selectedTab == 1 ? 1 : 0)
                }
                
                Spacer()
            }
        }
        
        .task {
            if subredditDetailsViewModel.subredditData == nil {
                await subredditDetailsViewModel.fetchSubredditDetails()
            }
        }
        .themedNavigationBar()
    }
}

