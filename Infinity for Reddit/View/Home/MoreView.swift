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
            Section(header: Text("Account").listSectionHeader()) {
                CustomNavigationLink("Profile", destination: ProfileView())
                
                CustomNavigationLink("Multireddit", destination: MultiredditView())
                
                CustomNavigationLink("History", destination: HistoryView())
            }
            .listPlainItem()
            
            Section(header: Text("Post").listSectionHeader()) {
                CustomNavigationLink("Upvoted", destination: UpvotedView())
                
                CustomNavigationLink("Downvoted", destination: DownvotedView())
                
                CustomNavigationLink("Hidden", destination: HiddenView())
                
                CustomNavigationLink("Saved", destination: SavedView())
            }
            .listPlainItem()
            
            Section(header: Text("Preferences").listSectionHeader()) {
                CustomNavigationLink("Settings", destination: SettingsView())
                
                CustomNavigationLink("Test", destination: TestView())
            }
            .listPlainItem()
        }
        .themedList()
    }
}
