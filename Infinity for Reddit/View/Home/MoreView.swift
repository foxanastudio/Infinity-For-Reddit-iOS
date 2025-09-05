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
    @EnvironmentObject var accountViewModel: AccountViewModel
    @Environment(\.dependencyManager) private var dependencyManager: Container
    
    var body: some View {
        List {
            Section(header: Text("Reddit").listSectionHeader()) {
                SimpleTouchItemRow(text: "Popular", icon: "flame") {
                    navigationManager.path.append(MoreViewNavigation.popular)
                }
                .listPlainItemNoInsets()
                
                SimpleTouchItemRow(text: "All", icon: "globe") {
                    navigationManager.path.append(MoreViewNavigation.all)
                }
                .listPlainItemNoInsets()
            }
            .listPlainItem()
            
            Section(header: Text("Account").listSectionHeader()) {
                if !accountViewModel.account.isAnonymous() {
                    SimpleTouchItemRow(text: "Profile", icon: "person.crop.circle") {
                        navigationManager.path.append(MoreViewNavigation.profile)
                    }
                    .listPlainItemNoInsets()
                }
                
                SimpleTouchItemRow(text: "History", icon: "clock") {
                    navigationManager.path.append(MoreViewNavigation.history)
                }
                .listPlainItemNoInsets()
            }
            .listPlainItem()
            
            if !accountViewModel.account.isAnonymous() {
                Section(header: Text("Post").listSectionHeader()) {
                    SimpleTouchItemRow(text: "Upvoted", icon:"arrowshape.up") {
                        navigationManager.path.append(MoreViewNavigation.upvoted)
                    }
                    .listPlainItemNoInsets()
                    
                    SimpleTouchItemRow(text: "Downvoted", icon: "arrowshape.down") {
                        navigationManager.path.append(MoreViewNavigation.downvoted)
                    }
                    .listPlainItemNoInsets()
                    
                    SimpleTouchItemRow(text: "Hidden", icon: "eye.slash") {
                        navigationManager.path.append(MoreViewNavigation.hidden)
                    }
                    .listPlainItemNoInsets()
                    
                    SimpleTouchItemRow(text: "Saved", icon: "bookmark.fill") {
                        navigationManager.path.append(MoreViewNavigation.saved)
                    }
                    .listPlainItemNoInsets()
                }
                .listPlainItem()
            }
            
            Section(header: Text("Preferences").listSectionHeader()) {
                SimpleTouchItemRow(text: "Settings", icon: "gearshape") {
                    navigationManager.path.append(MoreViewNavigation.settings)
                }
                .listPlainItemNoInsets()
                
                SimpleTouchItemRow(text: "Test", icon: "testtube.2") {
                    navigationManager.path.append(MoreViewNavigation.test)
                }
                .listPlainItemNoInsets()
            }
            .listPlainItem()
        }
        .themedList()
        .rootViewBackground()
    }
}
