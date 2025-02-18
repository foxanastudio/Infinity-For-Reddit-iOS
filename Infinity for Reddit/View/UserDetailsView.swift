//
//  UserDetailsView.swift
//  Infinity for Reddit
//
//  Created by joeylr2042 on 2025-02-08.
//

import SwiftUI

struct UserDetailsView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var accountViewModel: AccountViewModel
    @StateObject private var userDetailsViewModel = UserDetailsViewModel()
    
    @State private var selectedTab = 0
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Top Section (User Info)
                HStack(spacing: 0) {
                    if let profileImageUrl = accountViewModel.account.profileImageUrl {
                        AsyncImage(url: URL(string: profileImageUrl)) { phase in
                            switch phase {
                            case .empty:
                                ProgressView()
                            case .success(let image):
                                image
                                    .resizable()
                                    .scaledToFill()
                            case .failure:
                                SwiftUI.Image(systemName: "person.circle.fill")
                            @unknown default:
                                EmptyView()
                            }
                        }
                        .frame(width: 80, height: 80)
                        .clipShape(Circle())
                        .padding(.leading, 20)
                        .padding(.vertical, 20)
                    }
                    
                    VStack(alignment: .leading, spacing: 5) {
                        Text("u/\(accountViewModel.account.username)")
                            .font(.title2)
                            .bold()
                        
                        Button(action: {
                            print("Follow tapped")
                        }) {
                            Text("Follow")
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
                .frame(maxWidth: .infinity)
                
                // Stats Section
                Text("Karma: \(accountViewModel.account.karma)  Cake day: \(userDetailsViewModel.formattedCakeDay(accountViewModel.account.createdUTC))")
                    .padding(.leading, 30)
                    .frame(maxWidth:.infinity, alignment:.leading)
                
                
                // Posts and Comments Tabs
                HStack(spacing: 0) {
                    TabButton(
                        text: "Posts",
                        isSelected: selectedTab == 0,
                        action: { selectedTab = 0 }
                    )
                    TabButton(
                        text: "Comments",
                        isSelected: selectedTab == 1,
                        action: { selectedTab = 1 }
                    )
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 20)
                
                if selectedTab == 1 { 
                    VStack {
                        CommentListingView(
                            commentListingMetadata: CommentListingMetadata(
                                commentListingType:.user,
                                pathComponents: ["sortType": "best", "username": "\(accountViewModel.account.username)"],
                                headers: APIUtils.getOAuthHeader(accessToken: accountViewModel.account.accessToken ?? ""),
                                queries: nil,
                                params: nil
                            )
                        )
                        .id(accountViewModel.account.username)
                    }
                    .frame(maxHeight:.infinity)
                    Spacer()
                } else {
                    VStack{
                        PostListingView(
                            account: accountViewModel.account,
                            postListingMetadata:PostListingMetadata(
                                postListingType:.user,
                                pathComponents: ["sortType": "best", "username": "\(accountViewModel.account.username)"],
                                headers: APIUtils.getOAuthHeader(accessToken: accountViewModel.account.accessToken ?? ""),
                                queries: nil,
                                params: nil
                            )
                        )
                        .id(accountViewModel.account.username)
                    }.frame(maxHeight:.infinity)
                    Spacer()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1.0)))
            .edgesIgnoringSafeArea(.bottom)
        }
        .navigationTitle("User Details")
    }
}

struct TabButton: View {
    let text: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 0) {
                Text(text)
                    .foregroundColor(isSelected ? .blue : .black)
                    .bold()
                    .font(.system(size: 18))
                
                Rectangle()
                    .frame(height: 2)
                    .foregroundColor(isSelected ? .blue : .clear)
                    .frame(maxWidth: .infinity)
            }
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity)
        }
    }
}


