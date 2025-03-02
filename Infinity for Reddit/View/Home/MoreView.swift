//
//  MoreView.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2024-12-03.
//

import SwiftUI
import Swinject
import GRDB

struct MoreView: View {
    @Environment(\.dependencyManager) private var dependencyManager: Container
    
    var body: some View {
        List {
            Section(header: Text("Account")) {
                NavigationLink(destination: ProfileView()) {
                    Text("Profile")
                }
                NavigationLink(destination: MultiredditView()) {
                    Text("Multireddit")
                }
                NavigationLink(destination: HistoryView()) {
                    Text("History")
                }
            }
            .listPlainItem()
            .themedListSection()
            
            Section(header: Text("Post")) {
                NavigationLink(destination: UpvotedView()) {
                    Text("Upvoted")
                }
                NavigationLink(destination: DownvotedView()) {
                    Text("Downvoted")
                }
                NavigationLink(destination: HiddenView()) {
                    Text("Hidden")
                }
                NavigationLink(destination: SavedView()) {
                    Text("Saved")
                }
            }
            .listPlainItem()
            .themedListSection()
            
            Section(header: Text("Preferences")) {
                NavigationLink(destination: SettingsView()) {
                    Text("Settings")
                }
                NavigationLink(destination: TestView()) {
                    Text("Test")
                }
            }
            .listPlainItem()
            .themedListSection()
        }
        .themedList()
    }
}
