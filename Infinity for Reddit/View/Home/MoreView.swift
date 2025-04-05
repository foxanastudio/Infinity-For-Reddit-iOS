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
    @EnvironmentObject var navigationManager: NavigationManager
    @Environment(\.dependencyManager) private var dependencyManager: Container
    
    var body: some View {
        List {
            Section(header: Text("Account").listSectionHeader()) {
                Text("Profile")
                    .primaryText()
                    .onTapGesture {
                        navigationManager.path.append(MoreViewNavigation.profile)
                    }
                
                Text("History")
                    .primaryText()
                    .onTapGesture {
                        navigationManager.path.append(MoreViewNavigation.history)
                    }
            }
            .listPlainItem()
            
            Section(header: Text("Post").listSectionHeader()) {
                Text("Upvoted")
                    .primaryText()
                    .onTapGesture {
                        navigationManager.path.append(MoreViewNavigation.upvoted)
                    }
                
                Text("Downvoted")
                    .primaryText()
                    .onTapGesture {
                        navigationManager.path.append(MoreViewNavigation.downvoted)
                    }
                
                Text("Hidden")
                    .primaryText()
                    .onTapGesture {
                        navigationManager.path.append(MoreViewNavigation.hidden)
                    }
                
                Text("Saved")
                    .primaryText()
                    .onTapGesture {
                        navigationManager.path.append(MoreViewNavigation.saved)
                    }
            }
            .listPlainItem()
            
            Section(header: Text("Preferences").listSectionHeader()) {
                Text("Settings")
                    .primaryText()
                    .onTapGesture {
                        navigationManager.path.append(MoreViewNavigation.settings)
                    }
                
                Text("Test")
                    .primaryText()
                    .onTapGesture {
                        navigationManager.path.append(MoreViewNavigation.test)
                    }
            }
            .listPlainItem()
        }
        .themedList()
    }
}
