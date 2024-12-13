//
// InterfaceSettingsView.swift
// Infinity for Reddit
//
// Created by joeylr2042 on 2024-12-04
//

import SwiftUI
import Swinject
import GRDB

struct InterfaceSettingsView: View {
    @StateObject private var interfaceSettingsViewModel = InterfaceSettingsViewModel()
    
    var body: some View {
        List {
            NavigationLink(destination: FontInterfaceView()) {
                Label("Font", systemImage: "textformat.size")
            } 
            NavigationLink(destination: ImmersiveInterfaceView()) {
                Text("Immersive Interface").padding(.leading, 44.5)
            }
            NavigationLink(destination: NavigationDrawerInterfaceView()) {
                Text("Navigation Drawer").padding(.leading, 44.5)
            }
            Toggle("Hide FAB in Post Feed", isOn: $interfaceSettingsViewModel.hideFABInPostFeed).padding(.leading, 44.5)
            Toggle("Enable Bottom Navigation", isOn: $interfaceSettingsViewModel.enableBottomNavigation).padding(.leading, 44.5)
            Toggle("Hide Subreddit Description", isOn: $interfaceSettingsViewModel.hideSubredditDescription).padding(.leading, 44.5)
            Toggle("Use Bottom Toolbar in Media Viewer", isOn: $interfaceSettingsViewModel.useBottomToolbarInMediaViewer).padding(.leading, 44.5)
            Picker("Default Search Result Tab", selection: $interfaceSettingsViewModel.defaultSearchResultTab){
                ForEach(0..<interfaceSettingsViewModel.searchResultTabs.count, id: \.self) { index in
                    Text(interfaceSettingsViewModel.searchResultTabs[index]).tag(index)
                }
            }
            .padding(.leading, 44.5)
            NavigationLink(destination: TimeFormatInterfaceView()) {
                Text("Time Format").padding(.leading, 44.5)
            }
            NavigationLink(destination: PostInterfaceView()) {
                Text("Post").padding(.leading, 44.5)
            }
            NavigationLink(destination: PostDetailsInterfaceView()) {
                Text("Post Details").padding(.leading, 44.5)
            }
            NavigationLink(destination: InterfaceSettingsView()) {
                Text("Comment").padding(.leading, 44.5)
            }
            
            Section(header: Text("Post and Comment")){
                Toggle("Vote Buttons on the Right", isOn: $interfaceSettingsViewModel.voteButtonsOnTheRight).padding(.leading, 44.5)
                Toggle("Show Absolute Number of Votes", isOn: $interfaceSettingsViewModel.showAbsoluteNumberOfVotes).padding(.leading, 44.5)
            }
        }
        .navigationTitle("Interface")
    }
}


