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
    
    var body: some View {
        TabView {
            LoginView()
                .tabItem {
                    Label("Menu", systemImage: "list.dash")
                }
            
            SubscriptionsView()
                .tabItem {
                    Label("Subscriptions", systemImage: "list.dash")
                }
            
            InboxView()
                .tabItem {
                    Label("Inbox", systemImage: "list.dash")
                }
            
            MoreView()
                .tabItem {
                    Label("More", systemImage: "list.dash")
                }
        }
    }
}
