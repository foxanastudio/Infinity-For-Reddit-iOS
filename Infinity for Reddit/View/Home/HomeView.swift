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
    @Environment(\.dependencyManager) private var dependencyManager: Container
    @EnvironmentObject var accountViewModel: AccountViewModel
    
    @State private var selectedTab: Tab = .home
    @State private var showProfile: Bool = false
    
    var body: some View {
        NavigationView {
            VStack {
                TabView(selection: $selectedTab) {
                    PostListingView()
                        .tabItem {
                            Label("Home", systemImage: "house")
                        }
                        .tag(Tab.home)
                    
                    SubscriptionsView()
                        .tabItem {
                            Label("Subscriptions", systemImage: "book")
                        }
                        .tag(Tab.subscriptions)
                    
                    InboxView()
                        .tabItem {
                            Label("Inbox", systemImage: "envelope")
                        }
                        .tag(Tab.inbox)
                    
                    MoreView()
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
                    if let profileImageUrl = accountViewModel.account?.profileImageUrl {
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
                ProfileSheet()
            }
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
