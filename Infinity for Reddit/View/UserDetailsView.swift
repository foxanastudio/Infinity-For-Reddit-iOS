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
    
    @StateObject var userDetailsViewModel : UserDetailsViewModel
    @State private var selectedTab = 0
    @State private var isCurrentUserProfile: Bool = true
    @State private var subscribeTask: Task<Void, Never>?
    
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
        VStack(spacing: 0) {
            // Top Section (User Info)
            if let userData = userDetailsViewModel.userData {
                VStack(spacing: 0) {
                    HStack(spacing: 0) {
                        CustomWebImage(
                            userData.iconUrl,
                            width: userIconSize,
                            height: userIconSize,
                            circleClipped: true,
                            handleImageTapGesture: false,
                            fallbackView: {
                                InitialLetterAvatarImageFallbackView(name: userData.name, size: userIconSize)
                            }
                        )
                        .padding(.vertical, 20)
                        
                        VStack(alignment: .leading, spacing: 5) {
                            Text("u/\(userData.name)")
                                .username()
                                .font(.title2)
                                .bold()
                            
                            Button(action: {
                                subscribeTask?.cancel()
                                subscribeTask = Task {
                                    await userDetailsViewModel.toggleFollowUser()
                                }
                            }) {
                                Text(userDetailsViewModel.isSubscribed ? "Followed" : "Follow")
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
                    
                    HStack {
                        Text("Karma: \(userData.totalKarma ?? 0)")
                            .primaryText()
                        
                        Spacer()
                        
                        Text("Cake day: \(userDetailsViewModel.formattedCakeDay(userData.cakeday ?? 0))")
                            .primaryText()
                            .padding(.leading, 20)
                    }
                    .padding(.bottom, 10)
                    
                    if let description = userData.description, !description.isEmpty {
                        Markdown(description)
                            .themedMarkdown()
                            .padding(0)
                            .markdownLinkHandler { url in
                                navigationManager.openLink(url)
                            }
                    }
                    
                    SegmentedPicker(selectedValue: $selectedTab, values: ["Posts", "Comments"])
                        .padding(4)
                }
                .padding(.horizontal, 20)
                
                TabView(selection: $selectedTab) {
                    ZStack {
                        PostListingView(
                            postListingMetadata:PostListingMetadata(
                                postListingType:.user(username: userData.name, userWhere: .submitted),
                                pathComponents: ["username": "\(userData.name)"],
                                headers: APIUtils.getOAuthHeader(accessToken: accountViewModel.account.accessToken ?? ""),
                                queries: nil,
                                params: nil
                            ),
                            handleToolbarMenu: false
                        )
                        .id(accountViewModel.account.username)
                    }
                    .tag(0)
                    
                    ZStack {
                        CommentListingView(
                            commentListingMetadata: CommentListingMetadata(
                                commentListingType:.user(username: userData.name),
                                pathComponents: ["username": "\(userData.name)"],
                                headers: APIUtils.getOAuthHeader(accessToken: accountViewModel.account.accessToken ?? ""),
                                queries: nil
                            )
                        )
                        .id(accountViewModel.account.username)
                    }
                    .tag(1)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                
                Spacer()
            }
        }
        .task {
            if userDetailsViewModel.userData == nil {
                await userDetailsViewModel.fetchUserDetails()
            }
        }
        .themedNavigationBar()
        .toolbar {
            NavigationBarMenu()
        }
    }
}
