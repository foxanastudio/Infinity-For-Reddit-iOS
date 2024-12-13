//
//  NavigationDrawerInterfaceView.swift
//  Infinity for Reddit
//
//  Created by joeylr2042 on 2024-12-06.
//

import SwiftUI
import Swinject
import GRDB

struct NavigationDrawerInterfaceView: View {
    @StateObject var navigationDrawerInterfaceViewModel = NavigationDrawerInterfaceViewModel()
    
    var body: some View {
        List {
            Label("Restart the app to see the changes", systemImage: "info.circle")
                .foregroundColor(.blue)
                .font(.caption)
            
            Toggle(isOn: $navigationDrawerInterfaceViewModel.showAvatarOnRight) {
                Text("Show Avatar on the Right")
            }
            .padding(.leading, 44.5)
            
            Toggle(isOn: $navigationDrawerInterfaceViewModel.collapseAccountSection) {
                Text("Collapse Account Section")
            }
            .padding(.leading, 44.5)
        
            Toggle(isOn: $navigationDrawerInterfaceViewModel.collapseRedditSection) {
                Text("Collapse Reddit Section")
            }
            .padding(.leading, 44.5)
            
            Toggle(isOn: $navigationDrawerInterfaceViewModel.collapsePostSection) {
                Text("Collapse Post Section")
            }
            .padding(.leading, 44.5)
            
            Toggle(isOn: $navigationDrawerInterfaceViewModel.collapsePreferencesSection) {
                Text("Collapse Preferences Section")
            }
            .padding(.leading, 44.5)
            
            Toggle(isOn: $navigationDrawerInterfaceViewModel.collapseFavoriteSubredditsSection) {
                Text("Collapse Favorite Subreddits Section")
            }
            .padding(.leading, 44.5)
            
            Toggle(isOn: $navigationDrawerInterfaceViewModel.collapseSubscribedSubredditsSection) {
                Text("Collapse Subscribed Subreddits Section")
            }
            .padding(.leading, 44.5)
            
            Toggle(isOn: $navigationDrawerInterfaceViewModel.hideFavoriteSubredditsSection) {
                Text("Hide Favorite Subreddits Section")
            }
            .padding(.leading, 44.5)
            
            Toggle(isOn: $navigationDrawerInterfaceViewModel.hideSubscribedSubredditsSection) {
                Text("Hide Subscribed Subreddits Section")
            }
            .padding(.leading, 44.5)
            
            Toggle(isOn: $navigationDrawerInterfaceViewModel.hideAccountKarma) {
                Text("Hide Account Karma")
            }
            .padding(.leading, 44.5)
        }
        .navigationTitle("Navigation Drawer")
    }
}
