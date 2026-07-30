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
    
    @State private var activeAlert: ActiveAlert? = nil
    @State private var previouslyActiveAlertForAnimationCompletion: ActiveAlert? = nil
    @State private var handleLinkUrlString: String = ""
    @State private var subredditName: String = ""
    @State private var username: String = ""
    @FocusState private var focusedField: FieldType?
    
    var body: some View {
        RootView {
            List {
                CustomListSection("Reddit") {
                    SimpleTouchItemRow(text: "Popular", icon: "flame") {
                        navigationManager.append(MoreViewNavigation.popular)
                    }
                    .listPlainItemNoInsets()
                    .limitedWidth()
                    
                    SimpleTouchItemRow(text: "All", icon: "globe") {
                        navigationManager.append(MoreViewNavigation.all)
                    }
                    .listPlainItemNoInsets()
                    .limitedWidth()
                    
                    if !accountViewModel.account.isAnonymous() {
                        SimpleTouchItemRow(text: "Search", icon: "magnifyingglass") {
                            navigationManager.append(AppNavigation.search())
                        }
                        .listPlainItemNoInsets()
                        .limitedWidth()
                    }
                    
                    SimpleTouchItemRow(text: "Handle Link", icon: "link") {
                        withAnimation(.linear(duration: 0.2)) {
                            handleLinkUrlString = ""
                            activeAlert = .handleLink
                        }                        
                    }
                    .listPlainItemNoInsets()
                    .limitedWidth()
                    
                    SimpleTouchItemRow(text: "Go to Subreddit", icon: "bubble.left.and.text.bubble.right") {
                        withAnimation(.linear(duration: 0.2)) {
                            subredditName = ""
                            activeAlert = .goToSubreddit
                        }
                    }
                    .listPlainItemNoInsets()
                    .limitedWidth()
                    
                    SimpleTouchItemRow(text: "Go to User", icon: "person.crop.circle") {
                        withAnimation(.linear(duration: 0.2)) {
                            username = ""
                            activeAlert = .goToUser
                        }
                    }
                    .listPlainItemNoInsets()
                    .limitedWidth()
                }
                
                CustomListSection("Account") {
                    if !accountViewModel.account.isAnonymous() {
                        SimpleTouchItemRow(text: "Profile", icon: "person.crop.circle") {
                            navigationManager.append(AppNavigation.userDetails(username: accountViewModel.account.username))
                        }
                        .listPlainItemNoInsets()
                        .limitedWidth()
                    }
                    
                    SimpleTouchItemRow(text: "Upvoted", icon:"arrowshape.up") {
                        navigationManager.append(MoreViewNavigation.upvoted)
                    }
                    .listPlainItemNoInsets()
                    .limitedWidth()
                    
                    SimpleTouchItemRow(text: "Downvoted", icon: "arrowshape.down") {
                        navigationManager.append(MoreViewNavigation.downvoted)
                    }
                    .listPlainItemNoInsets()
                    .limitedWidth()
                    
                    SimpleTouchItemRow(text: "Hidden", icon: "eye.slash") {
                        navigationManager.append(MoreViewNavigation.hidden)
                    }
                    .listPlainItemNoInsets()
                    .limitedWidth()
                    
                    SimpleTouchItemRow(text: "Saved", icon: "bookmark.fill") {
                        navigationManager.append(MoreViewNavigation.saved)
                    }
                    .listPlainItemNoInsets()
                    .limitedWidth()
                    
                    SimpleTouchItemRow(text: "History", icon: "clock") {
                        navigationManager.append(MoreViewNavigation.history)
                    }
                    .listPlainItemNoInsets()
                    .limitedWidth()
                }
                
                if accountViewModel.account.isMod {
                    CustomListSection("Moderating") {
                        SimpleTouchItemRow(text: "Mod Mail", icon: "envelope.badge.shield.half.filled") {
                            navigationManager.append(MoreViewNavigation.modmail)
                        }
                        .listPlainItemNoInsets()
                        .limitedWidth()
                    }
                }
                
                CustomListSection("Preferences") {
                    SimpleTouchItemRow(text: "Settings", icon: "gearshape") {
                        navigationManager.append(MoreViewNavigation.settings)
                    }
                    .listPlainItemNoInsets()
                    .limitedWidth()
                    
                    SimpleTouchItemRow(text: "Test", icon: "testtube.2") {
                        navigationManager.append(MoreViewNavigation.test)
                    }
                    .listPlainItemNoInsets()
                    .limitedWidth()
                }
            }
            .themedList()
        }
        .overlay(
            CustomAlert(title: activeAlert?.title ?? "", confirmButtonText: "Go", isPresented: Binding(
                get: { activeAlert != nil },
                set: { newValue in
                    if !newValue {
                        activeAlert = nil
                    }
                }
            )) {
                switch activeAlert {
                case .handleLink:
                    CustomTextField(
                        "URL",
                        text: $handleLinkUrlString,
                        singleLine: true,
                        autocapitalization: .never,
                        fieldType: .handleLink,
                        focusedField: $focusedField
                    )
                    .urlTextField()
                    .submitLabel(.go)
                    .onSubmit {
                        withAnimation {
                            activeAlert = nil
                        } completion: {
                            navigationManager.openLink(handleLinkUrlString)
                        }
                    }
                case .goToSubreddit:
                    CustomTextField(
                        "Subreddit name",
                        text: $subredditName,
                        singleLine: true,
                        autocapitalization: .never,
                        fieldType: .subredditName,
                        focusedField: $focusedField
                    )
                    .submitLabel(.go)
                    .onSubmit {
                        guard !subredditName.isEmpty else {
                            return
                        }
                        navigationManager.append(AppNavigation.subredditDetails(subredditName: subredditName))
                        activeAlert = nil
                    }
                    
                    SubredditAutoCompleteView(query: $subredditName, itemPadding: 8) { subreddit in
                        navigationManager.append(
                            AppNavigation.subredditDetails(subredditName: subreddit.displayName)
                        )
                        withAnimation {
                            activeAlert = nil
                        }
                    }
                case .goToUser:
                    CustomTextField(
                        "Username",
                        text: $username,
                        singleLine: true,
                        autocapitalization: .never,
                        fieldType: .username,
                        focusedField: $focusedField
                    )
                    .submitLabel(.go)
                    .onSubmit {
                        guard !username.isEmpty else {
                            return
                        }
                        navigationManager.append(AppNavigation.userDetails(username: username))
                        activeAlert = nil
                    }
                case nil:
                    EmptyView()
                }
            } onConfirm: {
                if let alert = activeAlert {
                    switch alert {
                    case .handleLink:
                        previouslyActiveAlertForAnimationCompletion = .handleLink
                        focusedField = nil
                    case .goToSubreddit:
                        previouslyActiveAlertForAnimationCompletion = nil
                        guard !subredditName.isEmpty else {
                            return
                        }
                        navigationManager.append(AppNavigation.subredditDetails(subredditName: subredditName))
                    case .goToUser:
                        previouslyActiveAlertForAnimationCompletion = nil
                        guard !username.isEmpty else {
                            return
                        }
                        navigationManager.append(AppNavigation.userDetails(username: username))
                    }
                }
            } onConfirmAnimationCompleted: {
                // This is only for .handleLink cuz when a full screen media view that contains a TabView shows, the navigation bar will have a weird top padding. Stupid.
                if let alert = previouslyActiveAlertForAnimationCompletion {
                    switch alert {
                    case .handleLink:
                        previouslyActiveAlertForAnimationCompletion = nil
                        focusedField = nil
                        navigationManager.openLink(handleLinkUrlString)
                    default:
                        break
                    }
                }
            }
        )
    }
    
    enum FieldType: Hashable {
        case handleLink
        case subredditName
        case username
    }
}

private enum ActiveAlert: Identifiable {
    case handleLink, goToSubreddit, goToUser

    var id: Int {
        hashValue
    }
    
    var title: String {
        switch self {
        case .handleLink: return "Handle Link"
        case .goToSubreddit: return "Go to Subreddit"
        case .goToUser: return "Go to User"
        }
    }
}
