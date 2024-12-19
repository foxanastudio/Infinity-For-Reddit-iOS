//
//  ContentView.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2024-11-27.
//

import SwiftUI
import Swinject
import GRDB

struct HomeView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dependencyManager) private var dependencyManager: Container
    @EnvironmentObject var accountViewModel: AccountViewModel
    @EnvironmentObject var customThemeViewModel: CustomThemeViewModel
    
    @State private var selectedTab: Tab = .home
    @State private var showProfile: Bool = false
    
    var body: some View {
        NavigationStack {
            VStack {
                TabView(selection: $selectedTab) {
                    PostListingView(
                        postListingMetadata: PostListingMetadata(
                            postListingType: .frontPage,
                            pathComponents: ["sortType": "best"],
                            headers: APIUtils.getOAuthHeader(accessToken: accountViewModel.account.accessToken ?? ""),
                            queries: nil,
                            params: nil
                        )
                    )
                    .tabItem {
                        Label("Home", systemImage: "house")
                    }
                    .tag(Tab.home)
                    
                    SubscriptionsView()
                        .tabItem {
                            Label("Subscriptions", systemImage: "book")
                        }
                        .tag(Tab.subscriptions)
                    
                    CommentListingView(
                        commentListingMetadata: CommentListingMetadata(
                            commentListingType: .user,
                            pathComponents: ["sortType": "best"],
                            headers: APIUtils.getOAuthHeader(accessToken: accountViewModel.account.accessToken ?? ""),
                            queries: nil,
                            params: nil
                        )
                    )
                    .tabItem {
                        Label("Inbox", systemImage: "envelope")
                    }
                    .tag(Tab.inbox)
                    
                    LoginView()
                        .tabItem {
                            Label("More", systemImage: "person")
                        }
                        .tag(Tab.more)
                }
            }
            .navigationBarTitle(selectedTab.navigationTitle, displayMode: .inline)
            .navigationBarItems(
                leading: selectedTab.leadingButton,
                trailing: Button(action: {
                    showProfile.toggle()
                }) {
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
                                SwiftUI.Image(systemName: "person.circle.circle")
                            @unknown default:
                                EmptyView()
                            }
                        }
                        .frame(width: 48, height: 48)
                        .clipShape(.circle)
                    } else {
                        SwiftUI.Image(systemName: "person.crop.circle")
                            .resizable()
                            .frame(width: 30, height: 30)
                    }
                }
            )
            .sheet(isPresented: $showProfile) {
                AccountSheet()
                    .presentationDetents([.medium])
            }
            .onAppear {
                let dirPaths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)

                let docsDir = dirPaths[0]

                print(docsDir)
            }
        }
        .onChange(of: colorScheme) {
            customThemeViewModel.isDarkTheme = colorScheme == .dark
        }
    }
    
    enum Tab {
        case home, subscriptions, inbox, more
        
        var navigationTitle: String {
            switch self {
            case .home: return "Home"
            case .subscriptions: return "Subscriptions"
            case .inbox: return "Inbox"
            case .more: return "More"
            }
        }
        
        var leadingButton: AnyView? {
            switch self {
            case .home: return AnyView(Button(action: { print("Leading Action") }) { Text("Edit") })
            default: return nil
            }
        }
        
        var trailingButton: AnyView? {
            switch self {
            case .home: return AnyView(Button(action: { print("Search Home") }) { SwiftUI.Image(systemName: "magnifyingglass") })
            case .subscriptions: return AnyView(Button(action: { print("Manage Subscriptions") }) { Text("Manage") })
            default: return nil
            }
        }
    }
}
