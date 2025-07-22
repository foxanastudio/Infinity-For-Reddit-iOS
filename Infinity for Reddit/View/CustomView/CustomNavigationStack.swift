//
//  CustomNavigationStack.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-05-29.
//

import SwiftUI

struct CustomNavigationStack<Content: View>: View {
    @EnvironmentObject var accountViewModel: AccountViewModel
    
    @StateObject private var navigationManager = NavigationManager()
    
    let content: () -> Content
    
    var body: some View {
        NavigationStack(path: $navigationManager.path) {
            content()
                .navigationDestination(for: AppNavigation.self) { destination in
                    if case .login = destination {
                        LoginView()
                            .environmentObject(navigationManager)
                    } else if case .postDetails(let postDetailsInput, let isFromSubredditPostListing) = destination {
                        PostDetailsView(account: self.accountViewModel.account, postDetailsInput: postDetailsInput, isFromSubredditPostListing: isFromSubredditPostListing)
                            .environmentObject(navigationManager)
                    } else if case .postDetailsWithId(let postId, let commentId) = destination {
                        PostDetailsView(account: self.accountViewModel.account,
                                        postDetailsInput: PostDetailsInput.postAndCommentId(postId: postId, commentId: commentId),
                                        isFromSubredditPostListing: false
                        )
                        .environmentObject(navigationManager)
                    } else if case .userDetails(let username) = destination {
                        UserDetailsView(username: username)
                            .environmentObject(navigationManager)
                    } else if case .subredditDetails(let subredditName) = destination {
                        SubredditDetailsView(subredditName: subredditName)
                            .environmentObject(navigationManager)
                    } else if case .search(let query, let searchInSubredditOrUserName, let searchInMultiReddit, let searchInThingType) = destination {
                        SearchResultsView(query: query, searchInSubredditOrUserName: searchInSubredditOrUserName, searchInMultiReddit: searchInMultiReddit, searchInThingType: searchInThingType)
                            .environmentObject(navigationManager)
                    } else if case .customFeed(let myCustomFeed) = destination {
                        CustomFeedDetailsView(myCustomFeed: myCustomFeed)
                            .environmentObject(navigationManager)
                    } else if case .inboxConversation(let inbox) = destination {
                        InboxConversationView(inbox: inbox)
                            .environmentObject(navigationManager)
                    }
                }
                .navigationDestination(for: MoreViewNavigation.self) { destination in
                    switch destination {
                    case .popular:
                        PopularOrAllView(subredditName: "popular")
                            .environmentObject(navigationManager)
                    case .all:
                        PopularOrAllView(subredditName: "all")
                            .environmentObject(navigationManager)
                    case .profile:
                        UserDetailsView(username: self.accountViewModel.account.username)
                            .environmentObject(navigationManager)
                    case .history:
                        HistoryView()
                            .environmentObject(navigationManager)
                    case .upvoted:
                        UpvotedView()
                            .environmentObject(navigationManager)
                    case .downvoted:
                        DownvotedView()
                            .environmentObject(navigationManager)
                    case .hidden:
                        HiddenView()
                            .environmentObject(navigationManager)
                    case .saved:
                        SavedView()
                            .environmentObject(navigationManager)
                    case .settings:
                        SettingsView()
                            .environmentObject(navigationManager)
                    case .test:
                        TestView()
                            .environmentObject(navigationManager)
                    }
                }
                .navigationDestination(for: SettingsViewNavigation.self) { destination in
                    switch destination {
                    case .notification:
                        NotificationSettingsView()
                            .environmentObject(navigationManager)
                    case .interface:
                        InterfaceSettingsView()
                            .environmentObject(navigationManager)
                    case .theme:
                        CustomThemeSettingsView()
                            .environmentObject(navigationManager)
                    case .video:
                        VideoSettingsView()
                            .environmentObject(navigationManager)
                    case .gesturesAndButtons:
                        GestureButtonsSettingsView()
                            .environmentObject(navigationManager)
                    case .security:
                        SecuritySettingsView()
                            .environmentObject(navigationManager)
                    case .dataSavingMode:
                        EmptyView()
                    case .proxy:
                        EmptyView()
                    case .postHistory:
                        PostHistorySettingsView()
                            .environmentObject(navigationManager)
                    case .contentSensitivityFilter:
                        ContentSensitivityFilterSettingsView()
                            .environmentObject(navigationManager)
                    case .postFilter:
                        PostFilterSettingsView()
                            .environmentObject(navigationManager)
                    case .commentFilter:
                        CommentFilterSettingsView()
                            .environmentObject(navigationManager)
                    case .sortType:
                        EmptyView()
                    case .downloadLocation:
                        DownloadLocationSettingsView()
                            .environmentObject(navigationManager)
                    case .miscellaneous:
                        MiscellaneousSettingsView()
                            .environmentObject(navigationManager)
                    case .advanced:
                        AdvancedSettingsView()
                            .environmentObject(navigationManager)
                    case .manageSubscription:
                        ManageSubscriptionSettingsView()
                            .environmentObject(navigationManager)
                    case .about:
                        AboutSettingsView()
                            .environmentObject(navigationManager)
                    case .privacyPolicy:
                        PrivacyPolicySettingsView()
                            .environmentObject(navigationManager)
                    case .redditUserAgreement:
                        RedditUserAgreementSettingsView()
                            .environmentObject(navigationManager)
                    }
                }
                .navigationDestination(for: CustomThemeSettingsViewNavigation.self) { destination in
                    switch destination {
                    case .customizeCustomTheme(let customTheme):
                        CustomizeCustomThemeView(customTheme: customTheme)
                            .environmentObject(navigationManager)
                    case .customThemeListing:
                        CustomThemeListingView()
                            .environmentObject(navigationManager)
                    }
                }
                .environmentObject(navigationManager)
        }
        .themedNavigationBarBackButton()
    }
}
